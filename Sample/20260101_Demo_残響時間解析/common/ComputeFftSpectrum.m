function result = ComputeFftSpectrum(signal, fs, opts)
% ComputeFftSpectrum - 片側振幅スペクトルを計算する (窓補正込み・スケーリング規約固定)
%
% スケーリング規約:
%   - 窓の振幅補正 (GenerateWindow の amplitudeCorrection) を掛ける
%   - 片側化でDC・ナイキスト以外を2倍する
%   -> 振幅 A の正弦波を入れると amplitude がほぼ A になる
%
% 入力:
%   signal - [N x Ch] double 信号 (単位は任意: [Pa] なら結果も [Pa])
%   fs     - サンプリング周波数 [Hz]
%   opts.WindowType - 窓 'hann' (既定) | 'hamming' | 'blackman' | 'rect'
% 出力:
%   result.freqHz     [F x 1]  周波数 [Hz] (F = floor(N/2)+1)
%   result.amplitude  [F x Ch] 片側振幅スペクトル (入力と同じ単位)
%   result.fs         double   サンプリング周波数 [Hz]
%   result.windowType char     使用した窓
arguments
    signal (:, :) double {mustBeNonempty}
    fs (1, 1) double {mustBePositive}
    opts.WindowType {mustBeTextScalar} = 'hann'
end

numSamples = size(signal, 1);
[window, windowInfo] = GenerateWindow(char(opts.WindowType), numSamples);

windowed = signal .* window;
spectrum = fft(windowed, [], 1);

numBins = floor(numSamples / 2) + 1;
amplitude = abs(spectrum(1:numBins, :)) / numSamples * windowInfo.amplitudeCorrection;
% 片側化: DC(1) とナイキスト(偶数長のみ末尾) 以外は負周波数分を折り返して2倍
doubleMask = true(numBins, 1);
doubleMask(1) = false;
if mod(numSamples, 2) == 0
    doubleMask(end) = false;
end
amplitude(doubleMask, :) = 2 * amplitude(doubleMask, :);

result = struct( ...
    'freqHz', (0:numBins - 1).' * fs / numSamples, ...
    'amplitude', amplitude, ...
    'fs', fs, ...
    'windowType', char(opts.WindowType));
end
