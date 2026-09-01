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
analysisKey = HashArrays(prepared.inputHash);
cachePath = fullfile(thisDir, 'Cache', 'Proc02', 'spectrum.mat');
analyzed = RunCached(cachePath, analysisKey, ...
    @() AnalyzeAll(prepared.data), 'forceRecalc', params.forceRecalc);

fprintf('Proc02: %d件のスペクトルを計算しました -> %s\n', ...
    numel(analyzed.spectra), cachePath);

%% ---- ローカル関数 ----
function data = AnalyzeAll(prepared)
% 全波形の片側振幅スペクトルを計算する
numFiles = numel(prepared.audioList);
data = struct();
data.spectra = cell(1, numFiles);
data.nameList = prepared.nameList;
for k = 1:numFiles
    data.spectra{k} = ComputeOneSidedSpectrum(prepared.audioList{k}, ...
        prepared.fsList(k));
end
end

function result = ComputeOneSidedSpectrum(audioData, fs)
% 片側振幅スペクトル (窓なし・振幅スケーリング)
numSamples = size(audioData, 1);
spectrum = fft(audioData, [], 1) / numSamples;
half = floor(numSamples / 2) + 1;
amplitude = abs(spectrum(1:half, :)) * 2;
amplitude(1, :) = amplitude(1, :) / 2;
result = struct();
result.freqHz = (0:half - 1).' * fs / numSamples;
result.amplitude = amplitude;
end
