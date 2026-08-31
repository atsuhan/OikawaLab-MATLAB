% Proc02_Analyze - 解析本体 -> Cache/Proc02/spectrum.mat
%
% テンプレートの解析例として片側振幅スペクトルを計算する。
% 実験に合わせてこの段を書き換える (重い計算は必ず RunCached を通す)。
% 出力: Cache/Proc02/spectrum.mat
%   data.spectra  {1 x K} 各 struct (freqHz [F x 1], amplitude [F x Ch])
%   data.nameList {1 x K} ファイル名

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

%% スペクトル計算 (入力キャッシュのキー + 解析設定がこの段のキー)
analysisKey = HashArrays(prepared.inputHash, params.windowType);
cachePath = fullfile(thisDir, 'Cache', 'Proc02', 'spectrum.mat');
analyzed = RunCached(cachePath, analysisKey, ...
    @() AnalyzeAll(prepared.data, params), 'forceRecalc', params.forceRecalc);

fprintf('Proc02: %d件のスペクトルを計算しました -> %s\n', ...
    numel(analyzed.spectra), cachePath);

%% ---- ローカル関数 ----
function data = AnalyzeAll(prepared, params)
% 全波形の片側振幅スペクトルを計算する
numFiles = numel(prepared.audioList);
data = struct();
data.spectra = cell(1, numFiles);
data.nameList = prepared.nameList;
for k = 1:numFiles
    data.spectra{k} = ComputeFftSpectrum(prepared.audioList{k}, ...
        prepared.fsList(k), 'WindowType', params.windowType);
end
end
