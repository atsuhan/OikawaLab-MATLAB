function result = EstimateReverbTime(ir, fs)
% EstimateReverbTime - インパルス応答から残響時間を推定する (Schroeder逆積分法)
%
% 手順:
%   1) Schroeder逆積分でエネルギー減衰曲線 EDC を求める
%   2) EDC [dB] の指定区間を直線回帰し、-60 dB へ外挿して残響時間を得る
%      T20: -5 〜 -25 dB 区間 x3 / T30: -5 〜 -35 dB 区間 x2 / EDT: 0 〜 -10 dB 区間 x6
%
% 入力:
%   ir - [N x 1] double インパルス応答 (帯域制限する場合は事前に ApplyBandpassFilter)
%   fs - サンプリング周波数 [Hz]
% 出力:
%   result.t60FromT20   double  T20由来の残響時間 [s]
%   result.t60FromT30   double  T30由来の残響時間 [s]
%   result.edt          double  初期減衰時間 EDT [s]
%   result.decayCurveDb [N x 1] エネルギー減衰曲線 [dB] (0 dB 基準)
%   result.timeSec      [N x 1] 時刻 [s]
%
% 制約: 減衰レンジが足りない (EDCが-35 dBまで落ちない) 場合、該当推定値は NaN。
arguments
    ir (:, 1) double {mustBeNonempty}
    fs (1, 1) double {mustBePositive}
end

numSamples = numel(ir);
timeSec = (0:numSamples - 1).' / fs;

% Schroeder逆積分: EDC(t) = ∫t^inf ir^2 dτ
energy = ir .^ 2;
edc = flipud(cumsum(flipud(energy)));
decayCurveDb = 10 * log10(max(edc / edc(1), eps));

result = struct( ...
    't60FromT20', FitDecaySlope(timeSec, decayCurveDb, -5, -25, 3), ...
    't60FromT30', FitDecaySlope(timeSec, decayCurveDb, -5, -35, 2), ...
    'edt',        FitDecaySlope(timeSec, decayCurveDb, 0, -10, 6), ...
    'decayCurveDb', decayCurveDb, ...
    'timeSec', timeSec);
end

% =========================================================================
function t60 = FitDecaySlope(timeSec, decayCurveDb, upperDb, lowerDb, extrapolateFactor)
% 指定dB区間を直線回帰し -60 dB 相当へ外挿した残響時間を返す
upperIdx = find(decayCurveDb <= upperDb, 1, 'first');
lowerIdx = find(decayCurveDb <= lowerDb, 1, 'first');
if isempty(upperIdx) || isempty(lowerIdx) || lowerIdx - upperIdx < 10
    t60 = NaN;   % 減衰レンジ不足
    return
end

segmentTime = timeSec(upperIdx:lowerIdx);
segmentDb = decayCurveDb(upperIdx:lowerIdx);
coefficients = polyfit(segmentTime, segmentDb, 1);
slopeDbPerSec = coefficients(1);
if slopeDbPerSec >= 0
    t60 = NaN;   % 減衰していない
    return
end

segmentSpanSec = (upperDb - lowerDb) / (-slopeDbPerSec);
t60 = segmentSpanSec * extrapolateFactor;
end
