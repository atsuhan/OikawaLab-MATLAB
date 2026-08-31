function manifestPath = WriteExportManifest(exportDir, params, imagePaths)
%WriteExportManifest - Export成果物とParamsハッシュをmanifest.jsonへ記録する
%
% 「この図はどのパラメータで作ったのか」を後から追跡できるよう、Export フォルダに
% manifest.json (生成時刻 + Params構造体のSHA-256 + ファイル一覧) を書き出す。
% ExportFigure が返すパスをそのまま imagePaths に渡せる。
%
% 入力:
%   exportDir  - Export フォルダ (char/string。なければ作成)
%   params     - 実験パラメータ struct (Params() の戻り値)
%   imagePaths - 記録するファイルパス (char/string/cellstr。省略可)
% 出力:
%   manifestPath - 書き出した manifest.json の絶対パス
arguments
    exportDir {mustBeTextScalar}
    params (1, 1) struct
    imagePaths = {}
end

exportDir = char(exportDir);
if ~isfolder(exportDir), mkdir(exportDir); end
imagePaths = NormalizePaths(imagePaths);

manifest = struct();
manifest.generatedAt = char(datetime('now', ...
    'Format', 'yyyy-MM-dd''T''HH:mm:ssXXX', 'TimeZone', 'local'));
manifest.paramsHash = ['sha256:', HashParams(params)];
manifest.images = cellfun(@(p) RelativePath(p, exportDir), imagePaths, ...
    'UniformOutput', false);

manifestPath = fullfile(exportDir, 'manifest.json');
json = jsonencode(manifest, 'PrettyPrint', true);
fid = fopen(manifestPath, 'w', 'n', 'UTF-8');
if fid < 0
    error('WriteExportManifest:OpenFailed', ...
        'manifestを書き込めません: %s', manifestPath);
end
cleanup = onCleanup(@() fclose(fid));
fwrite(fid, json, 'char');
clear cleanup
end

% =========================================================================
function paths = NormalizePaths(value)
% char / string / cellstr を cellstr へ正規化
if isempty(value)
    paths = {};
elseif ischar(value) || (isstring(value) && isscalar(value))
    paths = {char(value)};
elseif isstring(value)
    paths = cellstr(value(:));
elseif iscell(value)
    paths = cellfun(@char, value(:), 'UniformOutput', false);
else
    error('WriteExportManifest:BadImagePaths', ...
        'imagePathsはchar/string/cellstrで指定してください。');
end
end

% =========================================================================
function relative = RelativePath(filePath, exportDir)
% exportDir 配下のパスを '/' 区切りの相対パスへ正規化
filePath = char(filePath);
prefix = [exportDir, filesep];
if startsWith(lower(filePath), lower(prefix))
    relative = extractAfter(filePath, strlength(prefix));
else
    relative = filePath;
end
relative = strrep(char(relative), '\', '/');
end

% =========================================================================
function hex = HashParams(params)
% Params構造体をフィールド順で正準化しSHA-256を返す
canonical = jsonencode(orderfields(params));
digest = java.security.MessageDigest.getInstance('SHA-256');
digest.update(unicode2native(canonical, 'UTF-8'));
bytes = typecast(digest.digest(), 'uint8');
hex = lower(reshape(dec2hex(bytes, 2).', 1, []));
end
