function SaveCacheMat(matPath, data, inputHash)
% SaveCacheMat - キャッシュ用matファイルを inputHash 付きで保存する
%
% RunCached の下請けだが、単独でも使用できる。保存内容は
%   data      (1,1) struct  計算結果 (フィールドに次元・単位をコメントで定義した変数群)
%   inputHash 1x64 char     HashArrays で生成した入力ハッシュ
%   createdAt char          保存時刻 (ISO8601)
% の3変数。読み込みは LoadCacheMat を使う。
%
% 入力:
%   matPath   - 保存先 .mat パス (親フォルダがなければ作成)
%   data      - 計算結果 struct
%   inputHash - 1x64 char (HashArrays の戻り値)
arguments
    matPath {mustBeTextScalar}
    data (1, 1) struct %#ok<INUSA> (-struct 保存で使用)
    inputHash (1, 64) char %#ok<INUSA>
end

matPath = char(matPath);
EnsureFolder(fileparts(matPath));

createdAt = char(datetime('now', ...
    'Format', 'yyyy-MM-dd''T''HH:mm:ssXXX', 'TimeZone', 'local')); %#ok<NASGU>

% 2GB 超の変数は -v7.3 でしか保存できないため、サイズで書式を切り替える
infoWhos = whos('data');
if infoWhos.bytes > 1.8e9
    save(matPath, 'data', 'inputHash', 'createdAt', '-v7.3');
else
    save(matPath, 'data', 'inputHash', 'createdAt');
end
end
