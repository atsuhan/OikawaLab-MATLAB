function [audioData, fs] = RecordMicrophone(requestedFs, durationSec, opts)
% RecordMicrophone - 既定マイクから録音する (audiorecorder ラッパー)
%
% 録音デバイスに依存するため Run には含めず Proc00 からのみ呼ぶ。
% 録音完了までブロックする。無音に近い録音・クリップは警告する。
%
% 入力:
%   requestedFs - 要求サンプリング周波数 [Hz]
%   durationSec - 録音時間 [s]
%   opts.NumChannels   - チャンネル数 (既定: 1)
%   opts.BitsPerSample - 量子化ビット数 [bit] (既定: 24)
% 出力:
%   audioData - [N x Ch] double、フルスケール±1 (未校正)
%   fs        - デバイスが実際に使ったサンプリング周波数 [Hz]
%               (要求値と異なる場合は警告する)
arguments
    requestedFs (1, 1) double {mustBePositive}
    durationSec (1, 1) double {mustBePositive}
    opts.NumChannels (1, 1) double {mustBePositive, mustBeInteger} = 1
    opts.BitsPerSample (1, 1) double {mustBeMember(opts.BitsPerSample, [8, 16, 24])} = 24
end

recorder = audiorecorder(requestedFs, opts.BitsPerSample, opts.NumChannels);
fs = recorder.SampleRate;
if fs ~= requestedFs
    warning('RecordMicrophone:FsFallback', ...
        '要求fs=%d Hz に対しデバイスの実fs=%d Hz で録音します。', requestedFs, fs);
end

fprintf('録音開始: %.1f 秒間 (fs=%d Hz, %d ch)...\n', durationSec, fs, opts.NumChannels);
recordblocking(recorder, durationSec);
fprintf('録音終了。\n');

audioData = getaudiodata(recorder, 'double');
if isempty(audioData)
    error('RecordMicrophone:NoData', ...
        '録音データが空です。マイクデバイスの接続とOSの入力設定を確認してください。');
end

% 録音品質の簡易チェック (無音・クリップの見逃し防止)
peakValue = max(abs(audioData(:)));
rmsValue = sqrt(mean(audioData(:) .^ 2));
if peakValue < 1e-4
    warning('RecordMicrophone:NearSilent', ...
        'ピーク %.2e とほぼ無音です。ミュート設定・入力デバイス選択を確認してください。', ...
        peakValue);
elseif peakValue >= 0.999
    warning('RecordMicrophone:Clipping', ...
        'ピークがフルスケールに達しておりクリップの可能性があります。入力ゲインを下げてください。');
end
fprintf('録音レベル: peak=%.3f, rms=%.4f (%.1f dBFS)\n', ...
    peakValue, rmsValue, 20 * log10(max(rmsValue, eps)));
end
