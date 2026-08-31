function [audioData, fs, info] = LoadAudioFile(filePath, opts)
% LoadAudioFile - 音声ファイルを読み込む (audioread ラッパー、単位規約つき)
%
% 入力:
%   filePath - 音声ファイルパス (.wav / .flac 等)
%   opts.CalibrationPaPerUnit - 校正係数 [Pa/FS]。指定するとフルスケール±1を
%                               音圧 [Pa] へ換算して返す (既定: NaN = 換算しない)
% 出力:
%   audioData - [N x Ch] double。校正係数なし: フルスケール±1の無次元値
%                              校正係数あり: 音圧 [Pa]
%   fs        - サンプリング周波数 [Hz]
%   info.filePath           char    読み込んだファイル
%   info.numSamples         double  N
%   info.numChannels        double  Ch
%   info.durationSec        double  信号長 [s]
%   info.isCalibrated       logical 音圧[Pa]へ換算済みか
%   info.calibrationPaPerUnit double 使用した校正係数 (未使用ならNaN)
arguments
    filePath {mustBeTextScalar}
    opts.CalibrationPaPerUnit (1, 1) double = NaN
end

filePath = char(filePath);
if ~isfile(filePath)
    error('LoadAudioFile:NotFound', '音声ファイルがありません: %s', filePath);
end

[audioData, fs] = audioread(filePath);
audioData = double(audioData);

isCalibrated = ~isnan(opts.CalibrationPaPerUnit);
if isCalibrated
    audioData = audioData * opts.CalibrationPaPerUnit;
end

info = struct( ...
    'filePath', filePath, ...
    'numSamples', size(audioData, 1), ...
    'numChannels', size(audioData, 2), ...
    'durationSec', size(audioData, 1) / fs, ...
    'isCalibrated', isCalibrated, ...
    'calibrationPaPerUnit', opts.CalibrationPaPerUnit);
end
