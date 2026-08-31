classdef RunCachedTest < matlab.unittest.TestCase
    % RunCachedTest - RunCached のキャッシュヒット/ミス/強制再計算を検証する

    properties
        TempDir
    end

    methods (TestMethodSetup)
        function createTempDir(testCase)
            testCase.TempDir = tempname();
            mkdir(testCase.TempDir);
            testCase.addTeardown(@() rmdir(testCase.TempDir, 's'));
        end
    end

    methods (Test)

        function firstCallComputesAndSaves(testCase)
            % 初回は必ず計算し、matファイルが作られること。
            matPath = fullfile(testCase.TempDir, 'Proc01', 'result.mat');
            key = HashArrays(42);

            counter = RunCachedTest.MakeCounter();
            [data, info] = RunCached(matPath, key, ...
                @() struct('value', counter()), 'verbose', false);

            testCase.verifyFalse(info.fromCache);
            testCase.verifyEqual(data.value, 1);
            testCase.verifyTrue(isfile(matPath), 'キャッシュmatが保存されていません。');
        end

        function secondCallWithSameKeyUsesCache(testCase)
            % 同じキーの2回目はキャッシュを使い、computeFcnを呼ばないこと。
            matPath = fullfile(testCase.TempDir, 'result.mat');
            key = HashArrays(1, 2, 3);
            counter = RunCachedTest.MakeCounter();
            computeFcn = @() struct('value', counter());

            RunCached(matPath, key, computeFcn, 'verbose', false);
            [data, info] = RunCached(matPath, key, computeFcn, 'verbose', false);

            testCase.verifyTrue(info.fromCache, '2回目がキャッシュヒットしていません。');
            testCase.verifyEqual(data.value, 1, 'computeFcnが再実行されています。');
        end

        function differentKeyTriggersRecompute(testCase)
            % 入力ハッシュが変わったら自動で再計算されること (誤再利用の防止)。
            matPath = fullfile(testCase.TempDir, 'result.mat');
            counter = RunCachedTest.MakeCounter();
            computeFcn = @() struct('value', counter());

            RunCached(matPath, HashArrays(1), computeFcn, 'verbose', false);
            [data, info] = RunCached(matPath, HashArrays(2), computeFcn, 'verbose', false);

            testCase.verifyFalse(info.fromCache, 'キー不一致なのにキャッシュが使われました。');
            testCase.verifyEqual(data.value, 2);
        end

        function forceRecalcIgnoresCache(testCase)
            % forceRecalc=true はキー一致でも再計算すること。
            matPath = fullfile(testCase.TempDir, 'result.mat');
            key = HashArrays(7);
            counter = RunCachedTest.MakeCounter();
            computeFcn = @() struct('value', counter());

            RunCached(matPath, key, computeFcn, 'verbose', false);
            [data, info] = RunCached(matPath, key, computeFcn, ...
                'forceRecalc', true, 'verbose', false);

            testCase.verifyFalse(info.fromCache);
            testCase.verifyEqual(data.value, 2);
        end

        function corruptedCacheFallsBackToRecompute(testCase)
            % スキーマ違いのmat (SaveCacheMat形式でない) はミス扱いで再計算に落ちること。
            matPath = fullfile(testCase.TempDir, 'result.mat');
            legacy = 123; %#ok<NASGU> (save で使用)
            save(matPath, 'legacy');

            counter = RunCachedTest.MakeCounter();
            [data, info] = RunCached(matPath, HashArrays(1), ...
                @() struct('value', counter()), 'verbose', false);

            testCase.verifyFalse(info.fromCache);
            testCase.verifyEqual(data.value, 1);
        end

        function nonStructComputeResultThrows(testCase)
            % computeFcn が struct 以外を返したら識別子付きエラーになること。
            matPath = fullfile(testCase.TempDir, 'result.mat');
            testCase.verifyError(...
                @() RunCached(matPath, HashArrays(1), @() 42, 'verbose', false), ...
                'RunCached:BadComputeResult');
        end

    end

    methods (Static, Access = private)
        function counter = MakeCounter()
            % 呼び出し回数を数えるクロージャ (computeFcn の実行回数検証用)
            count = 0;
            function value = increment()
                count = count + 1;
                value = count;
            end
            counter = @increment;
        end
    end
end
