function result = ComputeSpectrogram(signal, fs, opts)
% ComputeSpectrogram - STFTパワースペクトログラムを計算する (Toolbox非依存)
%
% 入力:
%   signal - [N x 1] double 信号 (単位は任意)
%   fs     - サンプリング周波数 [Hz]
%   opts.FrameSize  - フレーム長 [samples] (既定: 1024)
%   opts.HopSize    - ホップ長 [samples] (既定: FrameSize/2)
%   opts.WindowType - 窓 (既定: 'hann')
% 出力:
%   result.timeSec [T x 1] フレーム中心時刻 [s]
%   result.freqHz  [F x 1] 周波数 [Hz]
%   result.powerDb [F x T] パワー [dB re 入力単位^2] (10*log10)。
%                  片側スペクトルだが負周波数分の係数2は掛けない。
%                  DC/Nyquist の特別扱いもしない (可視化用の相対値。
%                  絶対レベルの主張には校正と定義の再確認が必要)
%   result.fs      double  サンプリング周波数 [Hz]
arguments
    signal (:, 1) double {mustBeNonempty}
    fs (1, 1) double {mustBePositive}
    opts.FrameSize (1, 1) double {mustBePositive, mustBeInteger} = 1024
    opts.HopSize (1, 1) double = NaN
    opts.WindowType {mustBeTextScalar} = 'hann'
end

frameSize = opts.FrameSize;
if isnan(opts.HopSize)
    hopSize = floor(frameSize / 2);
else
    hopSize = round(opts.HopSize);
    if hopSize < 1
        error('ComputeSpectrogram:InvalidHopSize', ...
            'HopSize は正の値で指定してください (指定値: %g)。', opts.HopSize);
    end
end

numSamples = numel(signal);
if numSamples < frameSize
    error('ComputeSpectrogram:SignalTooShort', ...
        '信号長 %d がフレーム長 %d より短いです。', numSamples, frameSize);
end

[window, windowInfo] = GenerateWindow(char(opts.WindowType), frameSize);

frameStarts = 1:hopSize:(numSamples - frameSize + 1);
numFrames = numel(frameStarts);
numBins = floor(frameSize / 2) + 1;

power = zeros(numBins, numFrames);
for frameIdx = 1:numFrames
    startIdx = frameStarts(frameIdx);
    frame = signal(startIdx:startIdx + frameSize - 1) .* window;
    spectrum = fft(frame);
    framePower = abs(spectrum(1:numBins)) .^ 2 / frameSize ^ 2 ...
        * windowInfo.powerCorrection;
    power(:, frameIdx) = framePower;
end

result = struct( ...
    'timeSec', (frameStarts.' - 1 + frameSize / 2) / fs, ...
    'freqHz', (0:numBins - 1).' * fs / frameSize, ...
    'powerDb', 10 * log10(max(power, eps)), ...
    'fs', fs);
end
