% Proc01_Prepare - データ読み込み・前処理 -> Cache/Proc01/prepared.mat
%
% Input/ の .wav をすべて読み込み、次段が使う形へ整えてキャッシュに保存する。
% 出力: Cache/Proc01/prepared.mat
%   data.audioList {1 x K} 各 [N x Ch] 波形 (校正済みなら [Pa])
%   data.fsList    [1 x K] サンプリング周波数 [Hz]
%   data.nameList  {1 x K} ファイル名

%% パス設定
thisDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisDir, '..', '..', 'Functions', 'Core'));
SetupProjectPaths(thisDir);
params = Params();

%% 入力一覧 (ファイル名・サイズ・更新時刻をキャッシュキーに使う)
inputFiles = dir(fullfile(thisDir, 'Input', '*.wav'));
if isempty(inputFiles)
    error('Proc01:NoInput', ...
        'Input/ に .wav がありません。READMEのInput契約に従いデータを置いてください。');
end
fileKey = HashArrays(string({inputFiles.name}), [inputFiles.bytes], ...
    [inputFiles.datenum], params.calibrationPaPerUnit);

%% 読み込み (入力ファイルが変わらない限りキャッシュを再利用)
cachePath = fullfile(thisDir, 'Cache', 'Proc01', 'prepared.mat');
prepared = RunCached(cachePath, fileKey, ...
    @() LoadAllInputs(inputFiles, params), 'forceRecalc', params.forceRecalc);

fprintf('Proc01: %d件の波形を準備しました -> %s\n', ...
    numel(prepared.audioList), cachePath);

%% ---- ローカル関数 ----
function data = LoadAllInputs(inputFiles, params)
% Input/ の全wavを読み込んで struct にまとめる
numFiles = numel(inputFiles);
data = struct();
data.audioList = cell(1, numFiles);
data.fsList = zeros(1, numFiles);
data.nameList = cell(1, numFiles);
for k = 1:numFiles
    filePath = fullfile(inputFiles(k).folder, inputFiles(k).name);
    [audioData, fs] = LoadAudioFile(filePath, ...
        'CalibrationPaPerUnit', params.calibrationPaPerUnit);
    if fs ~= params.expectedFs
        warning('Proc01:FsMismatch', ...
            '%s: fs=%d が Params.expectedFs=%d と一致しません。そのまま解析します。', ...
            inputFiles(k).name, fs, params.expectedFs);
    end
    data.audioList{k} = audioData;
    data.fsList(k) = fs;
    data.nameList{k} = inputFiles(k).name;
end
end
