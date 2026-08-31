function [signal, timeSec] = GenerateTestSignal(signalType, fs, durationSec, opts)
% GenerateTestSignal - テスト・デモ用の合成信号を生成する
%
% 実データなしで解析パイプラインを動かす・検証するための信号源。
% Toolbox 非依存 (すべて数式で生成)。
%
% 入力:
%   signalType  - 'sine' | 'chirp' | 'white' | 'pink' | 'impulse'
%   fs          - サンプリング周波数 [Hz]
%   durationSec - 信号長 [s]
%   opts.FreqHz      - sine の周波数 / chirp の開始周波数 [Hz] (既定: 1000)
%   opts.FreqEndHz   - chirp の終了周波数 [Hz] (既定: fs/4)
%   opts.Amplitude   - 振幅 (既定: 0.9)
%   opts.Seed        - 乱数シード (white/pink 用。既定: 42。再現性のため固定)
% 出力:
%   signal  - [N x 1] double 信号 (フルスケール±1想定)
%   timeSec - [N x 1] double 時刻 [s]
arguments
    signalType {mustBeMember(signalType, {'sine', 'chirp', 'white', 'pink', 'impulse'})}
    fs (1, 1) double {mustBePositive}
    durationSec (1, 1) double {mustBePositive}
    opts.FreqHz (1, 1) double {mustBePositive} = 1000
    opts.FreqEndHz (1, 1) double = NaN
    opts.Amplitude (1, 1) double {mustBePositive} = 0.9
    opts.Seed (1, 1) double {mustBeNonnegative} = 42
end

numSamples = round(durationSec * fs);
timeSec = (0:numSamples - 1).' / fs;
if isnan(opts.FreqEndHz)
    opts.FreqEndHz = fs / 4;
end

switch signalType
    case 'sine'
        signal = opts.Amplitude * sin(2 * pi * opts.FreqHz * timeSec);
    case 'chirp'
        % 線形チャープ: 瞬時周波数 f0 -> f1 (数式実装、Toolbox不要)
        sweepRate = (opts.FreqEndHz - opts.FreqHz) / durationSec;
        phase = 2 * pi * (opts.FreqHz * timeSec + 0.5 * sweepRate * timeSec .^ 2);
        signal = opts.Amplitude * sin(phase);
    case 'white'
        randomStream = RandStream('mt19937ar', 'Seed', opts.Seed);
        noise = randn(randomStream, numSamples, 1);
        signal = opts.Amplitude * noise / max(abs(noise));
    case 'pink'
        % FFT整形による 1/f ノイズ (振幅 ∝ 1/sqrt(f))
        randomStream = RandStream('mt19937ar', 'Seed', opts.Seed);
        whiteNoise = randn(randomStream, numSamples, 1);
        spectrum = fft(whiteNoise);
        freqIdx = (1:numSamples).';
        shaping = 1 ./ sqrt(max(freqIdx - 1, 1));
        % 実信号を保つため対称に整形 (正の周波数側を作って共役対称化)
        halfLen = floor(numSamples / 2);
        shaping(numSamples - (1:halfLen - 1) + 1) = shaping(2:halfLen);
        pinkNoise = real(ifft(spectrum .* shaping));
        signal = opts.Amplitude * pinkNoise / max(abs(pinkNoise));
    case 'impulse'
        signal = zeros(numSamples, 1);
        signal(1) = opts.Amplitude;
end
end
