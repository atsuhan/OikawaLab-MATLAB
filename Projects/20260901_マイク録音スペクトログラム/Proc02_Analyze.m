% Proc02_Analyze - スペクトログラム計算 -> Cache/Proc02/spectrogram.mat
%
% Proc01 で読み込んだ各録音の STFT パワースペクトログラムを計算する。
% 出力: Cache/Proc02/spectrogram.mat
%   data.spectrograms {1 x K} 各 struct (timeSec [T x 1] s, freqHz [F x 1] Hz,
%                     powerDb [F x T] dB, fs [Hz])
%   data.nameList     {1 x K} ファイル名

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

%% スペクトログラム計算 (入力キャッシュのキー + 解析設定がこの段のキー)
analysisKey = HashArrays(prepared.inputHash, params.frameSize, params.hopSize, ...
    string(params.windowType), 'ComputeSpectrogram.v1');
cachePath = fullfile(thisDir, 'Cache', 'Proc02', 'spectrogram.mat');
analyzed = RunCached(cachePath, analysisKey, ...
    @() AnalyzeAll(prepared.data, params), 'forceRecalc', params.forceRecalc);

fprintf('Proc02: %d件のスペクトログラムを計算しました -> %s\n', ...
    numel(analyzed.spectrograms), cachePath);

%% ---- ローカル関数 ----
function data = AnalyzeAll(prepared, params)
% 全録音のスペクトログラムを計算する (多chは第1chのみ解析)
numFiles = numel(prepared.audioList);
data = struct();
data.spectrograms = cell(1, numFiles);
data.nameList = prepared.nameList;
for k = 1:numFiles
    numChannels = size(prepared.audioList{k}, 2);
    if numChannels > 1
        warning('Proc02:MultiChannel', ...
            '%s: %d ch のうち第1chのみ解析します (他chは未使用)。', ...
            prepared.nameList{k}, numChannels);
    end
    signal = prepared.audioList{k}(:, 1);
    data.spectrograms{k} = ComputeSpectrogram(signal, prepared.fsList(k), ...
        'FrameSize', params.frameSize, ...
        'HopSize', params.hopSize, ...
        'WindowType', params.windowType);
end
end
