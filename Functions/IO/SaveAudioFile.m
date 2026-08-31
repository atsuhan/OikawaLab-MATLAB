function SaveAudioFile(filePath, audioData, fs)
% SaveAudioFile - 音声ファイルを書き出す (audiowrite ラッパー、クリップ検査つき)
%
% ±1 を超えるサンプルがあるとファイル形式によっては黙って歪むため、
% 書き出し前に検査してエラーにする (正規化は呼び出し側の責任で明示的に行う)。
%
% 入力:
%   filePath  - 出力パス (.wav / .flac。親フォルダがなければ作成)
%   audioData - [N x Ch] double、フルスケール±1
%   fs        - サンプリング周波数 [Hz]
arguments
    filePath {mustBeTextScalar}
    audioData (:, :) double {mustBeNonempty}
    fs (1, 1) double {mustBePositive}
end

peakValue = max(abs(audioData(:)));
if peakValue > 1
    error('SaveAudioFile:Clipping', ...
        'ピーク %.3f が±1を超えています。書き出し前に明示的に正規化してください。', ...
        peakValue);
end

filePath = char(filePath);
EnsureFolder(fileparts(filePath));
audiowrite(filePath, audioData, round(fs));
end
