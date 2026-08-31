% Proc02_EstimateRT - Schroeder減衰曲線と残響時間の推定 -> Cache/Proc02/reverb.mat
%
% 出力: Cache/Proc02/reverb.mat
%   data.reverb struct  EstimateReverbTime の結果
%                        (t60FromT20 / t60FromT30 / edt [s], decayCurveDb [N x 1])
%   data.fs     double  サンプリング周波数 [Hz]

%% パス設定
thisDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisDir, '..', '..', 'Functions', 'Core'));
SetupProjectPaths(thisDir);
params = Params();

%% 前段の読み込み
inputCachePath = fullfile(thisDir, 'Cache', 'Proc01', 'prepared.mat');
if ~isfile(inputCachePath)
    error('Proc02:NoInput', '前段の出力がありません。先に Proc01_Prepare を実行してください。');
end
prepared = LoadCacheMat(inputCachePath);

%% 残響時間推定 (前段のキーがこの段のキーの一部になる)
reverbKey = HashArrays(prepared.inputHash, 'EstimateReverbTime.v1');
cachePath = fullfile(thisDir, 'Cache', 'Proc02', 'reverb.mat');
analyzed = RunCached(cachePath, reverbKey, ...
    @() struct('reverb', EstimateReverbTime(prepared.data.ir, prepared.data.fs), ...
               'fs', prepared.data.fs), ...
    'forceRecalc', params.forceRecalc);

%% 正解値との照合 (このデモの核心: 解析の正しさを自分で確認できる)
estimatedT60 = analyzed.reverb.t60FromT30;
errorPercent = abs(estimatedT60 - params.t60TrueSec) / params.t60TrueSec * 100;
fprintf('Proc02: T60推定 = %.3f s (正解 %.2f s, 誤差 %.1f%%)\n', ...
    estimatedT60, params.t60TrueSec, errorPercent);
if errorPercent > 10
    warning('Proc02:LargeError', ...
        '推定誤差が10%%を超えています。IR長やノイズフロア設定を確認してください。');
end
