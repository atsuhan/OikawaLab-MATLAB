function ts = TimestampString()
% TimestampString - ファイル名用タイムスタンプ 'yyyyMMdd-HHmmss' を返す
%
% Export ファイル名・Reports フォルダ名の書式の単一正本。
% 例: '20260915-183042'
%
% 出力:
%   ts - 1x15 char

ts = char(datetime('now', 'Format', 'yyyyMMdd-HHmmss'));
end
