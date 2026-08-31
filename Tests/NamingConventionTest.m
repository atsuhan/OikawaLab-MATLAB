classdef NamingConventionTest < matlab.unittest.TestCase
    % NamingConventionTest - Functions配下の命名・構成規約を機械強制する
    %
    % docs/rules/project.md「MATLABコーディング規約」の実行部:
    %   - basename はリポジトリ全体で一意 (同名衝突による誤解決の防止)
    %   - Functions は2階層固定 (Functions/<Category>/<Name>.m)
    %   - PascalCase (大文字始まり)
    %   - classdef / +package / @class は Functions に置かない

    properties (Constant)
        RepoRoot = fileparts(fileparts(mfilename('fullpath')));
    end

    methods (Test)

        function functionsHaveUniqueBasenames(testCase)
            % Functions/ 配下で basename が重複しないこと。
            files = dir(fullfile(testCase.RepoRoot, 'Functions', '**', '*.m'));
            names = {files.name};
            [uniqueNames, ~, groupIdx] = unique(lower(names));
            counts = accumarray(groupIdx, 1);
            duplicated = uniqueNames(counts > 1);
            testCase.verifyEmpty(duplicated, sprintf( ...
                'Functions配下でbasenameが重複しています: %s', strjoin(duplicated, ', ')));
        end

        function functionsAreTwoLevelsDeep(testCase)
            % .m は必ず Functions/<Category>/ 直下 (深い階層や直下置きを禁止)。
            functionsDir = fullfile(testCase.RepoRoot, 'Functions');
            files = dir(fullfile(functionsDir, '**', '*.m'));
            for k = 1:numel(files)
                relative = erase(files(k).folder, [functionsDir, filesep]);
                parts = strsplit(relative, filesep);
                testCase.verifyEqual(numel(parts), 1, sprintf( ...
                    'Functions は2階層固定です (Functions/<Category>/<Name>.m): %s', ...
                    fullfile(files(k).folder, files(k).name)));
            end
        end

        function functionNamesArePascalCase(testCase)
            % ファイル名が大文字英字で始まること。
            files = dir(fullfile(testCase.RepoRoot, 'Functions', '**', '*.m'));
            for k = 1:numel(files)
                testCase.verifyTrue(~isempty(regexp(files(k).name, '^[A-Z]', 'once')), ...
                    sprintf('PascalCaseで命名してください: %s', files(k).name));
            end
        end

        function noClassdefOrPackagesInFunctions(testCase)
            % Functions に classdef / +package / @class フォルダを置かないこと。
            functionsDir = fullfile(testCase.RepoRoot, 'Functions');

            allEntries = dir(fullfile(functionsDir, '**', '*'));
            dirNames = {allEntries([allEntries.isdir]).name};
            badDirs = dirNames(startsWith(dirNames, '+') | startsWith(dirNames, '@'));
            testCase.verifyEmpty(badDirs, ...
                'Functions に +package / @class フォルダは置かない規約です。');

            files = dir(fullfile(functionsDir, '**', '*.m'));
            for k = 1:numel(files)
                content = fileread(fullfile(files(k).folder, files(k).name));
                firstCode = regexp(content, '^\s*(function|classdef)', ...
                    'tokens', 'once', 'lineanchors');
                testCase.verifyNotEmpty(firstCode, sprintf( ...
                    'function宣言で始まっていません: %s', files(k).name));
                testCase.verifyEqual(firstCode{1}, 'function', sprintf( ...
                    'classdef は Tests/ 以外に置かない規約です: %s', files(k).name));
            end
        end

    end
end
