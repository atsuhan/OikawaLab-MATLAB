classdef SignalProcessingTest < matlab.unittest.TestCase
    % SignalProcessingTest - 信号生成・スペクトル解析の数値検証
    %
    % 「振幅既知の正弦波を入れたら既知の読みが返る」を固定し、
    % スケーリング規約 (窓補正・片側化) の破壊を検知する。

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

        function sineSpectrumAmplitudeMatchesInput(testCase)
            % 振幅0.9・1kHzの正弦波 -> スペクトルのピークが 1kHz で振幅約0.9。
            fs = 48000;
            [signal, ~] = GenerateTestSignal('sine', fs, 1.0, 'FreqHz', 1000, ...
                'Amplitude', 0.9);
            result = ComputeFftSpectrum(signal, fs);

            [peakAmplitude, peakIdx] = max(result.amplitude);
            testCase.verifyEqual(result.freqHz(peakIdx), 1000, 'AbsTol', 2, ...
                'スペクトルのピーク周波数が入力周波数とずれています。');
            testCase.verifyEqual(peakAmplitude, 0.9, 'RelTol', 0.02, ...
                '窓補正込みの振幅スケーリングが壊れています。');
        end

        function rectWindowHasUnitCorrection(testCase)
            % 矩形窓の振幅補正係数は1 (補正の基準点)。
            [window, info] = GenerateWindow('rect', 256);
            testCase.verifyEqual(window, ones(256, 1));
            testCase.verifyEqual(info.amplitudeCorrection, 1, 'AbsTol', 1e-12);
        end

        function hannWindowCorrectionIsAboutTwo(testCase)
            % hann窓の振幅補正係数は約2 (窓の平均値が約0.5のため)。
            [~, info] = GenerateWindow('hann', 4096);
            testCase.verifyEqual(info.amplitudeCorrection, 2, 'RelTol', 0.01);
        end

        function spectrogramPeakTracksSineFrequency(testCase)
            % 正弦波のスペクトログラムは全フレームで同じ周波数ビンがピークになる。
            fs = 16000;
            [signal, ~] = GenerateTestSignal('sine', fs, 0.5, 'FreqHz', 2000);
            result = ComputeSpectrogram(signal, fs, 'FrameSize', 512);

            testCase.verifySize(result.powerDb, ...
                [numel(result.freqHz), numel(result.timeSec)]);
            [~, peakIdx] = max(result.powerDb, [], 1);
            peakFreqs = result.freqHz(peakIdx);
            testCase.verifyEqual(peakFreqs, repmat(2000, numel(peakFreqs), 1), ...
                'AbsTol', fs / 512 + 1, ...
                'スペクトログラムのピークが正弦波周波数を追跡していません。');
        end

        function noiseGenerationIsReproducibleWithSeed(testCase)
            % 同じシードなら同じ信号 (再現性)、違うシードなら異なる信号。
            [noiseA, ~] = GenerateTestSignal('white', 8000, 0.1, 'Seed', 7);
            [noiseB, ~] = GenerateTestSignal('white', 8000, 0.1, 'Seed', 7);
            [noiseC, ~] = GenerateTestSignal('white', 8000, 0.1, 'Seed', 8);

            testCase.verifyEqual(noiseA, noiseB, ...
                '同一シードで信号が再現されません。');
            testCase.verifyNotEqual(noiseA, noiseC);
        end

        function bandpassFilterAttenuatesOutOfBand(testCase)
            % 帯域外の正弦波が強く減衰し、帯域内はほぼ素通しになること。
            % (Signal Processing Toolbox 依存。未導入環境では assumption で skip)
            testCase.assumeTrue(license('test', 'Signal_Toolbox') == 1, ...
                'Signal Processing Toolbox がないためスキップします。');

            fs = 48000;
            [inBand, ~]  = GenerateTestSignal('sine', fs, 0.5, 'FreqHz', 1000);
            [outBand, ~] = GenerateTestSignal('sine', fs, 0.5, 'FreqHz', 8000);

            filteredIn  = ApplyBandpassFilter(inBand, fs, [500 2000]);
            filteredOut = ApplyBandpassFilter(outBand, fs, [500 2000]);

            % 過渡部を除いた中央区間のRMSで比較
            core = round(0.1 * fs):round(0.4 * fs);
            rmsIn  = rms(filteredIn(core))  / rms(inBand(core));
            rmsOut = rms(filteredOut(core)) / rms(outBand(core));

            testCase.verifyGreaterThan(rmsIn, 0.95, '帯域内が減衰しすぎています。');
            testCase.verifyLessThan(rmsOut, 0.01, '帯域外の減衰が不足しています。');
        end

    end
end
