% Proc00_CheckInput - 入力データの目視確認 (初回のみ手動実行。Runには含めない)
%
% Input/ の .wav を一覧表示し、先頭ファイルの波形をプロットする。
% ここで「チャンネル対応・長さ・振幅・fs」がREADMEの記載と合っているかを
% 目で確認してから Proc01 以降へ進む。

%% パス設定
thisDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisDir, '..', '..', 'Functions', 'Core'));
SetupProjectPaths(thisDir);
params = Params();

%% Input/ の一覧
inputFiles = dir(fullfile(thisDir, 'Input', '*.wav'));
if isempty(inputFiles)
    error('Proc00:NoInput', ...
        'Input/ に .wav がありません。READMEのInput契約に従いデータを置いてください。');
end
fprintf('Input/ の .wav: %d件\n', numel(inputFiles));
for k = 1:numel(inputFiles)
    fprintf('  %2d: %s (%.1f MB)\n', k, inputFiles(k).name, inputFiles(k).bytes / 1e6);
end

%% 先頭ファイルの波形を目視確認
[audioData, fs, info] = LoadAudioFile( ...
    fullfile(inputFiles(1).folder, inputFiles(1).name), ...
    'CalibrationPaPerUnit', params.calibrationPaPerUnit);
fprintf('fs = %d Hz / %d ch / %.2f s\n', fs, info.numChannels, info.durationSec);
if fs ~= params.expectedFs
    warning('Proc00:FsMismatch', ...
        'fs=%d が Params.expectedFs=%d と一致しません。READMEとParamsを確認してください。', ...
        fs, params.expectedFs);
end

figure('Name', 'Proc00: 波形確認');
timeSec = (0:size(audioData, 1) - 1).' / fs;
plot(timeSec, audioData);
xlabel('時間 [s]');
ylabel('振幅');
title(inputFiles(1).name, 'Interpreter', 'none');
ApplyFigureStyle(gcf, params.figPreset);
