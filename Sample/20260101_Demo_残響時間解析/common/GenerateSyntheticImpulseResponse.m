function [ir, timeSec, info] = GenerateSyntheticImpulseResponse(fs, t60Sec, durationSec, opts)
% GenerateSyntheticImpulseResponse - 残響時間が既知の合成インパルス応答を生成する
%
% 指数減衰する白色雑音でIRを模擬する。設定した T60 が「正解値」になるため、
% 残響時間推定 (EstimateReverbTime) の検証・教材データとして使う。
% エネルギー減衰 E(t) = exp(-13.8155 t / T60) (T60 秒で -60 dB)。
%
% 入力:
%   fs          - サンプリング周波数 [Hz]
%   t60Sec      - 目標残響時間 T60 [s]
%   durationSec - IR長 [s] (T60 より十分長くする。推奨 1.5*T60 以上)
%   opts.NoiseFloorDb - ノイズフロア [dB] (直接音基準。既定: -80)
%   opts.Seed         - 乱数シード (既定: 42。再現性のため固定)
% 出力:
%   ir      - [N x 1] double インパルス応答 (ピーク±1未満に正規化)
%   timeSec - [N x 1] double 時刻 [s]
%   info.t60Sec       double 設定した正解T60 [s]
%   info.noiseFloorDb double 設定したノイズフロア [dB]
%   info.fs           double サンプリング周波数 [Hz]
arguments
    fs (1, 1) double {mustBePositive}
    t60Sec (1, 1) double {mustBePositive}
    durationSec (1, 1) double {mustBePositive}
    opts.NoiseFloorDb (1, 1) double {mustBeNegative} = -80
    opts.Seed (1, 1) double {mustBeNonnegative} = 42
end

numSamples = round(durationSec * fs);
timeSec = (0:numSamples - 1).' / fs;

% 振幅包絡: エネルギーが T60 で -60 dB になる指数減衰
decayRate = 6.9078 / t60Sec;   % = ln(10^3) / T60 (振幅で-60dB/T60の半分)
envelope = exp(-decayRate * timeSec);

randomStream = RandStream('mt19937ar', 'Seed', opts.Seed);
carrier = randn(randomStream, numSamples, 1);
noiseFloor = 10 ^ (opts.NoiseFloorDb / 20) * randn(randomStream, numSamples, 1);

ir = carrier .* envelope + noiseFloor;
ir = ir / max(abs(ir)) * 0.99;

info = struct('t60Sec', t60Sec, 'noiseFloorDb', opts.NoiseFloorDb, 'fs', fs);
end
