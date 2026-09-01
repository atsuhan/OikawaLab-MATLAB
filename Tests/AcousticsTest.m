classdef AcousticsTest < matlab.unittest.TestCase
    % AcousticsTest - Sample内の音響関数の数値検証 (既知の正解値と突合)

    methods (TestClassSetup)
        function addSampleCommonToPath(testCase)
            thisDir = fileparts(mfilename('fullpath'));
            commonDir = fullfile(fileparts(thisDir), 'Sample', ...
                '20260101_Demo_残響時間解析', 'common');
            testCase.applyFixture( ...
                matlab.unittest.fixtures.PathFixture(commonDir));
        end
    end

    methods (Test)

        function referencePressureIsZeroDb(testCase)
            % 基準音圧 20 µPa は 0 dB。
            testCase.verifyEqual(ConvertPaToDb(20e-6), 0, 'AbsTol', 1e-10);
        end

        function onePascalIsAbout94Db(testCase)
            % 1 Pa は約 93.98 dB (音響校正器の標準値)。
            testCase.verifyEqual(ConvertPaToDb(1), 93.98, 'AbsTol', 0.01);
        end

        function dbConversionRoundTrips(testCase)
            % Pa -> dB -> Pa の往復が一致する。
            pressures = [20e-6, 0.01, 0.5, 1, 2];
            roundTrip = ConvertDbToPa(ConvertPaToDb(pressures));
            testCase.verifyEqual(roundTrip, pressures, 'RelTol', 1e-10);
        end

        function aWeightingMatchesStandardValues(testCase)
            % IEC 61672 の代表値: 1 kHz = 0 dB / 100 Hz = -19.1 dB / 10 kHz = -2.5 dB。
            testCase.verifyEqual(GetAWeightingDb(1000), 0, 'AbsTol', 0.05);
            testCase.verifyEqual(GetAWeightingDb(100), -19.1, 'AbsTol', 0.3);
            testCase.verifyEqual(GetAWeightingDb(10000), -2.5, 'AbsTol', 0.3);
        end

        function soundSpeedAt20DegreesIsStandard(testCase)
            % 20 degC で約 343.2 m/s、0 degC で約 331.3 m/s。
            testCase.verifyEqual(GetSoundSpeed(20), 343.2, 'AbsTol', 0.5);
            testCase.verifyEqual(GetSoundSpeed(0), 331.3, 'AbsTol', 0.1);
        end

        function reverbTimeMatchesSyntheticGroundTruth(testCase)
            % 正解T60=1.0sの合成IR -> 推定T60が誤差5%以内 (パイプラインの数値保証)。
            fs = 48000;
            trueT60 = 1.0;
            [ir, ~, ~] = GenerateSyntheticImpulseResponse(fs, trueT60, 2.0);

            result = EstimateReverbTime(ir, fs);

            testCase.verifyEqual(result.t60FromT30, trueT60, 'RelTol', 0.05, ...
                'T30由来の残響時間が正解値から5%以上ずれています。');
            testCase.verifyEqual(result.t60FromT20, trueT60, 'RelTol', 0.05, ...
                'T20由来の残響時間が正解値から5%以上ずれています。');
            testCase.verifyEqual(result.decayCurveDb(1), 0, 'AbsTol', 1e-10, ...
                '減衰曲線は0 dB始まりであるべき。');
        end

        function shortIrReturnsNaNInsteadOfError(testCase)
            % 減衰レンジが足りないIRでは NaN を返す (誤った数値を返さない)。
            fs = 48000;
            shortIr = ones(100, 1);   % 減衰しない信号
            result = EstimateReverbTime(shortIr, fs);
            testCase.verifyTrue(isnan(result.t60FromT30), ...
                '減衰レンジ不足はNaNで表現する契約です。');
        end

    end
end
