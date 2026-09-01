function [audioData, fs] = RecordMicrophone(fs, durationSec, opts)
% RecordMicrophone - 既定マイクから録音する (audiorecorder ラッパー)
%
% 録音デバイスに依存するため Run には含めず Proc00 からのみ呼ぶ。
% 録音完了までブロックする。
%
% 入力:
%   fs          - サンプリング周波数 [Hz]
%   durationSec - 録音時間 [s]
%   opts.NumChannels   - チャンネル数 (既定: 1)
%   opts.BitsPerSample - 量子化ビット数 [bit] (既定: 24)
% 出力:
%   audioData - [N x Ch] double、フルスケール±1 (未校正)
%   fs        - サンプリング周波数 [Hz] (入力をそのまま返す)
arguments
    fs (1, 1) double {mustBePositive}
    durationSec (1, 1) double {mustBePositive}
    opts.NumChannels (1, 1) double {mustBePositive, mustBeInteger} = 1
    opts.BitsPerSample (1, 1) double {mustBeMember(opts.BitsPerSample, [8, 16, 24])} = 24
end

recorder = audiorecorder(fs, opts.BitsPerSample, opts.NumChannels);
fprintf('録音開始: %.1f 秒間 (fs=%d Hz, %d ch)...\n', durationSec, fs, opts.NumChannels);
recordblocking(recorder, durationSec);
fprintf('録音終了。\n');

audioData = getaudiodata(recorder, 'double');
if isempty(audioData)
    error('RecordMicrophone:NoData', ...
        '録音データが空です。マイクデバイスの接続とOSの入力設定を確認してください。');
end
end
