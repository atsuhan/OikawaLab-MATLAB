function weightDb = GetAWeightingDb(freqHz)
% GetAWeightingDb - 周波数ごとのA特性重み [dB] を返す (IEC 61672-1)
%
% SPLスペクトルへ加算して使う: splA = spl + GetAWeightingDb(freqHz)。
% 1 kHz で 0 dB になるよう正規化されている。
%
% 入力:
%   freqHz - 周波数 [Hz] (任意サイズの配列、正の値)
% 出力:
%   weightDb - 同サイズのA特性重み [dB]
arguments
    freqHz double {mustBePositive}
end

f2 = freqHz .^ 2;
% IEC 61672-1 の定義定数
c1 = 12194 ^ 2;
c2 = 20.6 ^ 2;
c3 = 107.7 ^ 2;
c4 = 737.9 ^ 2;

numerator = c1 * f2 .^ 2;
denominator = (f2 + c2) .* sqrt((f2 + c3) .* (f2 + c4)) .* (f2 + c1);
responseLinear = numerator ./ denominator;

% 1 kHz で 0 dB になる正規化定数 (+2.00 dB)
weightDb = 20 * log10(responseLinear) + 2.00;
end
