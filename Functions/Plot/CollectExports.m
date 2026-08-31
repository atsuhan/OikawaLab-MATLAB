function report = CollectExports(projectDirs, reportDir, opts)
% CollectExports - 実験のExport図をReportsフォルダへ収集し、出所を記録する
%
% 各実験の Export/ から図をコピーし、Export/manifest.json の paramsHash を
% sources.json へ転記する。「発表資料のこの図はどのパラメータで作ったか」を
% 後から追跡できるようにする (研究の再現性の要)。
%
% 使い方 (ゼミ資料の材料集め):
%   CollectExports({'Projects/20260915_残響測定'}, 'Reports/20260920_ゼミ発表_残響')
%
% 入力:
%   projectDirs - 実験フォルダのcell配列 (絶対/相対パス)
%   reportDir   - 収集先のReportsフォルダ (assets/ とsources.jsonを作る)
%   opts.FilePattern - 収集するファイルパターン (既定: '*.png')
% 出力:
%   report.copiedFiles  cellstr 収集したファイル (assets/内の絶対パス)
%   report.sourcesPath  char    書き出した sources.json のパス
arguments
    projectDirs (1, :) cell {mustBeNonempty}
    reportDir {mustBeTextScalar}
    opts.FilePattern {mustBeTextScalar} = '*.png'
end

reportDir = char(reportDir);
assetsDir = EnsureFolder(fullfile(reportDir, 'assets'));

sources = {};
copiedFiles = {};

for p = 1:numel(projectDirs)
    projectDir = char(projectDirs{p});
    exportDir = fullfile(projectDir, 'Export');
    if ~isfolder(exportDir)
        warning('CollectExports:NoExport', 'Exportフォルダがありません: %s', exportDir);
        continue
    end

    manifest = ReadManifestIfPresent(exportDir);

    files = dir(fullfile(exportDir, char(opts.FilePattern)));
    for k = 1:numel(files)
        sourcePath = fullfile(files(k).folder, files(k).name);
        targetPath = fullfile(assetsDir, files(k).name);
        copyfile(sourcePath, targetPath);
        copiedFiles{end + 1} = targetPath; %#ok<AGROW> 件数は少数

        entry = struct();
        entry.file = files(k).name;
        entry.sourceProject = strrep(projectDir, '\', '/');
        if isempty(manifest)
            entry.paramsHash = 'unknown';
            entry.generatedAt = 'unknown';
        else
            entry.paramsHash = manifest.paramsHash;
            entry.generatedAt = manifest.generatedAt;
        end
        sources{end + 1} = entry; %#ok<AGROW> 件数は少数
    end
end

sourcesPath = fullfile(reportDir, 'sources.json');
json = jsonencode(struct('collectedAt', ...
    char(datetime('now', 'Format', 'yyyy-MM-dd''T''HH:mm:ss')), ...
    'sources', {sources}), 'PrettyPrint', true);
fid = fopen(sourcesPath, 'w', 'n', 'UTF-8');
if fid < 0
    error('CollectExports:OpenFailed', 'sources.jsonを書き込めません: %s', sourcesPath);
end
cleanup = onCleanup(@() fclose(fid));
fwrite(fid, json, 'char');
clear cleanup

report = struct('copiedFiles', {copiedFiles}, 'sourcesPath', sourcesPath);
end

% =========================================================================
function manifest = ReadManifestIfPresent(exportDir)
% Export/manifest.json があれば読み込む (なければ空)
manifestPath = fullfile(exportDir, 'manifest.json');
if isfile(manifestPath)
    manifest = jsondecode(fileread(manifestPath));
else
    manifest = [];
end
end
