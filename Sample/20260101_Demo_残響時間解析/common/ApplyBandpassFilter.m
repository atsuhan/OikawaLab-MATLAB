function filtered = ApplyBandpassFilter(signal, fs, bandHz, opts)
% ApplyBandpassFilter - ゼロ位相バンドパスフィルタ (butter + filtfilt)
%
% 依存: Signal Processing Toolbox (butter / filtfilt)。
% SPT依存はこの関数に隔離する (他のAnalysis関数はToolbox非依存)。
%
% 入力:
%   signal - [N x Ch] double 信号
%   fs     - サンプリング周波数 [Hz]
%   bandHz - [1 x 2] 通過帯域 [下限 上限] [Hz] (0 < 下限 < 上限 < fs/2)
%   opts.Order - フィルタ次数 (既定: 4。filtfiltで実効2倍)
% 出力:
%   filtered - [N x Ch] double ゼロ位相フィルタ後の信号 (入力と同じ単位)
arguments
    signal (:, :) double {mustBeNonempty}
    fs (1, 1) double {mustBePositive}
    bandHz (1, 2) double {mustBePositive}
    opts.Order (1, 1) double {mustBePositive, mustBeInteger} = 4
end

nyquistHz = fs / 2;
if bandHz(1) >= bandHz(2) || bandHz(2) >= nyquistHz
    error('ApplyBandpassFilter:BadBand', ...
        '帯域 [%.1f %.1f] Hz が不正です (0 < 下限 < 上限 < fs/2 = %.1f)。', ...
        bandHz(1), bandHz(2), nyquistHz);
end

[b, a] = butter(opts.Order, bandHz / nyquistHz, 'bandpass');
filtered = filtfilt(b, a, signal);
end
