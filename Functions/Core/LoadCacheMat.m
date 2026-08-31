function cached = LoadCacheMat(matPath)
% LoadCacheMat - SaveCacheMat で保存したキャッシュmatを読み込む
%
% 入力:
%   matPath - .mat パス
% 出力:
%   cached.data      (1,1) struct  計算結果
%   cached.inputHash 1x64 char     保存時の入力ハッシュ
%   cached.createdAt char          保存時刻
%
% ファイルが存在しない・スキーマが違う場合は識別子付きエラーを投げる。
arguments
    matPath {mustBeTextScalar}
end

matPath = char(matPath);
if ~isfile(matPath)
    error('LoadCacheMat:NotFound', 'キャッシュmatがありません: %s', matPath);
end

cached = load(matPath);
if ~isfield(cached, 'data') || ~isfield(cached, 'inputHash')
    error('LoadCacheMat:BadSchema', ...
        'SaveCacheMat 形式ではありません (data/inputHash がない): %s', matPath);
end
end
