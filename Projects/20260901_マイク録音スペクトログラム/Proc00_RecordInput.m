% Proc00_RecordInput - マイク録音 + 目視確認 (手動実行。Runには含めない)
%
% 既定マイクから params.recordDurationSec 秒録音して
% Input/recording_<yyyyMMdd-HHmmss>.wav に保存し、波形を目視確認する。
% ここで「長さ・振幅・無音でないか」を目で確認してから Run へ進む。
% 録音デバイスに依存するためヘッドレス実行 (matlab -batch) の対象外。

%% パス設定
thisDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisDir, '..', '..', 'Functions', 'Core'));
SetupProjectPaths(thisDir);
params = Params();

%% 録音
[audioData, fs] = RecordMicrophone(params.expectedFs, params.recordDurationSec, ...
    'NumChannels', params.recordNumChannels, ...
    'BitsPerSample', params.recordBitsPerSample);

%% 保存 (生データは Input/ へ。既存ファイルは上書きしない命名)
timeStamp = char(datetime('now', 'Format', 'yyyyMMdd-HHmmss'));
outputPath = fullfile(thisDir, 'Input', ['recording_', timeStamp, '.wav']);
SaveAudioFile(outputPath, audioData, fs, 'BitsPerSample', params.recordBitsPerSample);
fprintf('保存しました: %s (peak=%.3f)\n', outputPath, max(abs(audioData(:))));

%% 波形の目視確認
figure('Name', 'Proc00: 録音波形の確認');
timeSec = (0:size(audioData, 1) - 1).' / fs;
plot(timeSec, audioData);
xlabel('時間 [s]');
ylabel('振幅 (フルスケール±1)');
title(['recording_', timeStamp, '.wav'], 'Interpreter', 'none');
ApplyFigureStyle(gcf, params.figPreset);
