classdef SampleSmokeTest < matlab.unittest.TestCase
    % SampleSmokeTest - Sampleデモ実験の一気通貫実行と数値検証
    %
    % 「clone直後にデモが完走する」ことがこのリポジトリのゴールのひとつ。
    %   - Run.m がヘッドレスで完走する
    %   - Export/ に図2枚と manifest.json が出る
    %   - 推定T60が設定した正解値の10%以内
    % を検証する。生成物 (Input/Cache/Export) はテスト後に削除する。

    properties
        DemoDir
    end

    methods (TestClassSetup)
        function locateDemo(testCase)
            testsDir = fileparts(which('SampleSmokeTest'));
            repoRoot = fileparts(testsDir);
            testCase.DemoDir = fullfile(repoRoot, 'Sample', '20260101_Demo_残響時間解析');
            testCase.assertTrue(isfolder(testCase.DemoDir), ...
                'Sampleデモ実験フォルダが見つかりません。');
        end
    end

    methods (TestMethodSetup)
        function cleanGeneratedFolders(testCase)
            % 実行前後に生成フォルダを掃除する (テストの決定性と作業環境の清潔さ)
            testCase.RemoveGeneratedFolders();
            testCase.addTeardown(@() testCase.RemoveGeneratedFolders());
            % path もテストで書き換わるため復元する
            originalPath = path();
            testCase.addTeardown(@() path(originalPath));
        end
    end

    methods (Test)

        function demoRunsHeadlessAndProducesExports(testCase)
            % Run.m 完走 -> 図2枚 + manifest + T60精度 を一括検証。
            run(fullfile(testCase.DemoDir, 'Run.m'));

            % --- Export の確認 ---
            exportDir = fullfile(testCase.DemoDir, 'Export');
            pngFiles = dir(fullfile(exportDir, '*.png'));
            testCase.verifyGreaterThanOrEqual(numel(pngFiles), 2, ...
                'デモは減衰曲線とスペクトログラムの2枚以上を出力するはず。');

            manifestPath = fullfile(exportDir, 'manifest.json');
            testCase.verifyTrue(isfile(manifestPath), 'manifest.jsonがありません。');
            manifest = jsondecode(fileread(manifestPath));
            testCase.verifyTrue(startsWith(manifest.paramsHash, 'sha256:'));

            % --- 数値検証: 推定T60 が正解の10%以内 ---
            params = testCase.LoadDemoParams();
            reverbCache = load(fullfile(testCase.DemoDir, 'Cache', 'Proc02', 'reverb.mat'));
            estimated = reverbCache.data.reverb.t60FromT30;
            testCase.verifyEqual(estimated, params.t60TrueSec, ...
                'RelTol', 0.10, sprintf( ...
                '推定T60 %.3f s が正解 %.2f s から10%%以上ずれています。', ...
                estimated, params.t60TrueSec));
        end

        function secondRunUsesCache(testCase)
            % 2回目の Run はキャッシュが効いて再計算されないこと (体験の核)。
            run(fullfile(testCase.DemoDir, 'Run.m'));
            reverbCachePath = fullfile(testCase.DemoDir, 'Cache', 'Proc02', 'reverb.mat');
            firstInfo = dir(reverbCachePath);

            run(fullfile(testCase.DemoDir, 'Run.m'));
            secondInfo = dir(reverbCachePath);

            testCase.verifyEqual(secondInfo.datenum, firstInfo.datenum, ...
                '2回目のRunでキャッシュが再計算されています (キーが不安定な疑い)。');
        end

    end

    methods (Access = private)

        function RemoveGeneratedFolders(testCase)
            generated = {'Input', 'Cache', 'Export'};
            for k = 1:numel(generated)
                target = fullfile(testCase.DemoDir, generated{k});
                if isfolder(target)
                    rmdir(target, 's');
                end
            end
        end

        function params = LoadDemoParams(testCase)
            % デモの Params.m を path 衝突なしに評価する
            currentDir = pwd();
            cleanup = onCleanup(@() cd(currentDir));
            cd(testCase.DemoDir);
            params = Params();
            clear cleanup
        end
    end
end
