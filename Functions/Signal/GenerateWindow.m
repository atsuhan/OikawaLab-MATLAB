function [window, info] = GenerateWindow(windowType, windowLength)
% GenerateWindow - 窓関数と振幅補正係数を返す (Toolbox非依存の数式実装)
%
% 入力:
%   windowType   - 'hann' | 'hamming' | 'blackman' | 'rect'
%   windowLength - 窓長 [samples]
% 出力:
%   window - [L x 1] double 窓
%   info.amplitudeCorrection double 振幅補正係数 (= L / sum(window)。
%                                    正弦波振幅を窓なしと同じ読みにする)
%   info.powerCorrection     double パワー補正係数 (= L / sum(window.^2))
arguments
    windowType {mustBeMember(windowType, {'hann', 'hamming', 'blackman', 'rect'})}
    windowLength (1, 1) double {mustBePositive, mustBeInteger}
end

if windowLength == 1
    % L=1 では下式が 0/0 になるため単一点窓を直接返す
    window = 1;
    info = struct('amplitudeCorrection', 1, 'powerCorrection', 1);
    return;
end

n = (0:windowLength - 1).';
switch windowType
    case 'hann'
        window = 0.5 - 0.5 * cos(2 * pi * n / (windowLength - 1));
    case 'hamming'
        window = 0.54 - 0.46 * cos(2 * pi * n / (windowLength - 1));
    case 'blackman'
        window = 0.42 - 0.5 * cos(2 * pi * n / (windowLength - 1)) ...
            + 0.08 * cos(4 * pi * n / (windowLength - 1));
    case 'rect'
        window = ones(windowLength, 1);
end

info = struct( ...
    'amplitudeCorrection', windowLength / sum(window), ...
    'powerCorrection', windowLength / sum(window .^ 2));
end
