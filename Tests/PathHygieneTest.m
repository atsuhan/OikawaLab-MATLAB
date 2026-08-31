classdef PathHygieneTest < matlab.unittest.TestCase
    % PathHygieneTest - MATLAB path の一意性 (どのファイルが解決されるかの決定性) を検証
    %
    % 背景:
    %   Projects/ と Sample/ 配下には同名ファイル (Params.m・Proc01_*.m など) が
    %   実験ごとに存在する。リポジトリ全体を addpath(genpath()) すると解決先が
    %   不定になる (移植元リポジトリで実害があった)。本テストは以下を機械的に守る。
    %     (a) 実験フォルダの .m が Functions の関数名を隠していない
    %     (b) 実験フォルダに「Functions 以外を genpath する addpath」が残っていない
    %     (b') 各実験の Run.m が SetupProjectPaths を呼んでいる
    %     (c) SetupProjectPaths 実行後、他実験の Params.m が path に乗っていない
    %
    % 検査対象の実験は動的に列挙する (実験を追加すると自動で検査対象になる)。

    methods (Test)

        function experimentsDoNotShadowFunctions(testCase)
            % (a) 実験フォルダの .m 名が Functions の関数名と衝突しないこと。
            repoRoot = PathHygieneTest.RepoRoot();
            functionFiles = dir(fullfile(repoRoot, 'Functions', '**', '*.m'));
            functionNames = lower(string({functionFiles.name}));

            offenders = {};
            experiments = PathHygieneTest.ListExperiments();
            for i = 1:numel(experiments)
                files = dir(fullfile(experiments{i}, '**', '*.m'));
                for k = 1:numel(files)
                    if ismember(lower(string(files(k).name)), functionNames)
                        offenders{end + 1} = fullfile(files(k).folder, files(k).name); %#ok<AGROW> 通常0件
                    end
                end
            end

            testCase.verifyEmpty(offenders, sprintf( ...
                '実験フォルダの .m が Functions の関数名を隠しています:\n%s', ...
                strjoin(offenders, newline)));
        end

        function experimentsHaveNoRepoWideGenpath(testCase)
            % (b) Functions 以外を genpath する addpath が実験に残っていないこと。
            offenders = {};
            experiments = PathHygieneTest.ListExperiments();
            for i = 1:numel(experiments)
                files = dir(fullfile(experiments{i}, '**', '*.m'));
                for k = 1:numel(files)
                    fullPath = fullfile(files(k).folder, files(k).name);
                    hits = PathHygieneTest.FindBadGenpathLines(fullPath);
                    for h = 1:numel(hits)
                        offenders{end + 1} = sprintf('%s:%d: %s', ...
                            fullPath, hits(h).line, hits(h).text); %#ok<AGROW> 通常0件
                    end
                end
            end

            testCase.verifyEmpty(offenders, sprintf( ...
                ['Functions 以外を genpath する addpath が残っています' ...
                ' (SetupProjectPaths へ置換してください):\n%s'], ...
                strjoin(offenders, newline)));
        end

        function runScriptsUseSetupProjectPaths(testCase)
            % (b') 各実験の Run*.m が SetupProjectPaths を呼んでいること。
            experiments = PathHygieneTest.ListExperiments();
            for i = 1:numel(experiments)
                runFiles = dir(fullfile(experiments{i}, 'Run*.m'));
                for k = 1:numel(runFiles)
                    fullPath = fullfile(runFiles(k).folder, runFiles(k).name);
                    text = fileread(fullPath);
                    testCase.verifySubstring(text, 'SetupProjectPaths(', sprintf( ...
                        '%s が SetupProjectPaths 経由になっていません。', fullPath));
                end
            end
        end

        function setupProjectPathsIsolatesOtherExperiments(testCase)
            % (c) SetupProjectPaths 後、他実験の Params.m が path に乗っていないこと。
            repoRoot = PathHygieneTest.RepoRoot();

            % path はテスト内で書き換えるため必ず復元する
            originalPath = path();
            testCase.addTeardown(@() path(originalPath));

            experiments = PathHygieneTest.ListExperiments();
            % Params.m を持つ実験だけを隔離検証の対象にする
            hasParams = cellfun(@(d) isfile(fullfile(d, 'Params.m')), experiments);
            targets = experiments(hasParams);
            testCase.assertNotEmpty(targets, ...
                'Params.m を持つ実験が1件もありません (テンプレート破損の疑い)。');

            for i = 1:numel(targets)
                projectDir = targets{i};

                % 検証条件を厳しくするため、まず全実験を path に載せてから整える
                path(originalPath);
                addpath(genpath(fullfile(repoRoot, 'Projects')));
                addpath(genpath(fullfile(repoRoot, 'Sample')));
                info = SetupProjectPaths(projectDir);

                resolved = which('Params', '-all');
                foreign = resolved(~startsWith(lower(resolved), ...
                    lower([projectDir filesep])));
                % Functions 配下に Params.m は存在しない規約なので、残っていたら全て異物
                testCase.verifyEmpty(foreign, sprintf( ...
                    '実験 %s の path に他実験の Params.m が残っています:\n%s', ...
                    projectDir, strjoin(foreign, newline)));

                testCase.verifyTrue(startsWith(lower(which('Params')), ...
                    lower([projectDir filesep])), sprintf( ...
                    '実験 %s で which(''Params'') が %s を指しています。', ...
                    projectDir, which('Params')));

                % Functions は path に残ること
                testCase.verifyTrue(ismember(lower(fullfile(repoRoot, 'Functions')), ...
                    lower(info.added)), 'Functions が path に追加されていません。');
            end
        end
    end

    methods (Static, Access = private)

        function root = RepoRoot()
            % 本テストファイル (Tests/ 直下) からリポジトリルートを導出する
            testsDir = fileparts(which('PathHygieneTest'));
            root = fileparts(testsDir);
        end

        function experiments = ListExperiments()
            % Projects/ と Sample/ 直下の実験フォルダを列挙する
            % ('_' 始まり = _template/_archive は実験ではないが、_template は
            %  規約のお手本なので (a)(b)(b') の検査対象に含める)
            root = PathHygieneTest.RepoRoot();
            experiments = {};
            roots = {fullfile(root, 'Projects'), fullfile(root, 'Sample')};
            for r = 1:numel(roots)
                entries = dir(roots{r});
                for k = 1:numel(entries)
                    name = entries(k).name;
                    if ~entries(k).isdir || startsWith(name, '.') ...
                            || strcmp(name, '_archive')
                        continue
                    end
                    experiments{end + 1} = fullfile(roots{r}, name); %#ok<AGROW> 件数は少数
                end
            end
        end

        function hits = FindBadGenpathLines(filePath)
            % 「Functions を含まない genpath を addpath する」行を抽出 (コメント行は除外)
            hits = struct('line', {}, 'text', {});
            lines = splitlines(string(fileread(filePath)));
            for i = 1:numel(lines)
                lineText = strtrim(lines(i));
                if lineText == "" || startsWith(lineText, '%')
                    continue
                end
                tokens = regexp(lineText, 'addpath\s*\(\s*genpath\s*\((.*?)\)\s*\)', ...
                    'tokens', 'once');
                if isempty(tokens)
                    continue
                end
                if ~contains(tokens(1), 'Functions')
                    hits(end + 1) = struct('line', i, 'text', char(lineText)); %#ok<AGROW> 通常0件
                end
            end
        end
    end
end
