function info = SetupProjectPaths(projectDir, varargin)
%SetupProjectPaths - 「Functions + 当該実験のみ」に MATLAB path を整える
%
% 目的:
%   Projects/ や Sample/ 配下には同名ファイル（Params.m・Proc01_*.m など）が
%   複数の実験に存在するため、`addpath(genpath(pwd))` のようにリポジトリ全体を
%   path に載せると、どの実験のファイルが解決されるかが不定になる。
%   本関数は「Functions 全体 + 指定実験（+ 明示依存の実験フォルダ）だけを path に
%   載せ、それ以外の Projects\ / Sample\ 配下パスを path から外す」ことで
%   解決先を一意にする。
%
% 使い方:
%   SetupProjectPaths(thisDir);                                   % 単独実験
%   SetupProjectPaths(thisDir, 'dependsOn', {baseProjDir});       % 他実験の common を参照
%   info = SetupProjectPaths(thisDir);                            % 変更内容を受け取る
%
% 入力:
%   projectDir      - 対象実験フォルダ（絶対/相対パス。char または string）
%   'dependsOn'     - 明示依存する他実験フォルダの cell 配列（既定: {}）。
%                     依存先は **ルート直下を path に載せない**（依存先の Params.m や
%                     Proc*.m が当該実験のものを隠さないようにするため）。
%                     .m を含むサブフォルダ（common, common/_helpers 等）だけを追加する。
%   'excludeFolders'- path 追加対象から除外するフォルダ名の cell 配列
%                     （既定: {'Input','Cache','Export'} = データ置き場）
%   'verbose'       - 追加/削除したパスを表示するか（既定: false）
%
% 出力:
%   info.projectDir   char      正規化した実験フォルダ
%   info.repoRoot     char      リポジトリルート（本関数の位置から導出）
%   info.functionsDir char      Functions フォルダ
%   info.added        cellstr   addpath したフォルダ（先頭が最優先）
%   info.removed      cellstr   rmpath した Projects/Sample 配下フォルダ
%   info.previousPath char      呼び出し前の path（`path(info.previousPath)` で復元可）
%
% 規約:
%   - path の優先順は「実験 > 明示依存 > Functions」（同名なら実験側が勝つ）
%   - Projects\_archive\ 配下（凍結実験）は無条件で path から外す。
%   - Tests\ 配下・Functions\ 配下など Projects/Sample 以外の path は一切触らない。

opt = ParseArguments(varargin);

repoRoot     = GetRepoRoot();
functionsDir = fullfile(repoRoot, 'Functions');
if ~isfolder(functionsDir)
    error('SetupProjectPaths:FunctionsNotFound', ...
        'Functions フォルダが見つかりません: %s', functionsDir);
end

projectDir = CanonicalizeFolder(projectDir, 'projectDir');
dependsOn  = cellfun(@(d) CanonicalizeFolder(d, 'dependsOn'), opt.dependsOn, ...
    'UniformOutput', false);

% ---- path に載せるフォルダを決める（優先順に連結） ----
projectFolders = CollectCodeFolders(projectDir, true,  opt.excludeFolders);
depFolders     = cellfun(@(d) CollectCodeFolders(d, false, opt.excludeFolders), ...
    dependsOn, 'UniformOutput', false);
depFolders     = UniqueStable([depFolders{:}]);
functionsFolders = CollectCodeFolders(functionsDir, true, {});

addFolders = UniqueStable([projectFolders, depFolders, functionsFolders]);

% ---- 現在の path から「載せる対象ではない Projects/Sample 配下」を外す ----
previousPath = path();
entries      = SplitPathList(previousPath);
isExperiment = cellfun(@IsUnderExperimentRoots, entries);
keepMask     = ismember(NormalizeForCompare(entries), NormalizeForCompare(addFolders));
removeMask   = isExperiment & ~keepMask;
removeFolders = entries(removeMask);

if ~isempty(removeFolders)
    warnState = warning('off', 'MATLAB:rmpath:DirNotFound');
    rmpath(strjoin(removeFolders, pathsep));
    warning(warnState);
end

% addpath は指定順のまま path 先頭に積むため、実験 → 依存 → Functions の優先順になる
addpath(strjoin(addFolders, pathsep));

info = struct( ...
    'projectDir',   projectDir, ...
    'repoRoot',     repoRoot, ...
    'functionsDir', functionsDir, ...
    'added',        {addFolders}, ...
    'removed',      {removeFolders}, ...
    'previousPath', previousPath);

if opt.verbose
    fprintf('SetupProjectPaths: 実験=%s\n', projectDir);
    fprintf('  追加 %d フォルダ / Projects/Sample 配下から除去 %d フォルダ\n', ...
        numel(addFolders), numel(removeFolders));
    cellfun(@(p) fprintf('  - removed: %s\n', p), removeFolders);
end

end

% =========================================================================
function opt = ParseArguments(args)
% 名前つき引数の解析（既定値つき）
p = inputParser();
p.FunctionName = 'SetupProjectPaths';
addParameter(p, 'dependsOn', {}, @(v) iscell(v) || ischar(v) || isstring(v));
addParameter(p, 'excludeFolders', {'Input', 'Cache', 'Export'}, ...
    @(v) iscell(v) || ischar(v) || isstring(v));
addParameter(p, 'verbose', false, @(v) islogical(v) && isscalar(v));
parse(p, args{:});

opt = p.Results;
opt.dependsOn      = ToCellStr(opt.dependsOn);
opt.excludeFolders = ToCellStr(opt.excludeFolders);
end

% =========================================================================
function repoRoot = GetRepoRoot()
% 本ファイルは <repoRoot>/Functions/Core/ に置かれる前提でルートを導出する
thisDir      = fileparts(mfilename('fullpath'));   % Functions/Core
functionsDir = fileparts(thisDir);                 % Functions
repoRoot     = fileparts(functionsDir);            % リポジトリルート
end

% =========================================================================
function out = CanonicalizeFolder(folder, argName)
% 相対パス・'..' を含むパスを実在する絶対パスへ正規化する
folder = ToCellStr(folder);
if numel(folder) ~= 1
    error('SetupProjectPaths:BadFolderArg', '%s は単一のフォルダパスで指定してください。', argName);
end
folder = folder{1};
if ~isfolder(folder)
    error('SetupProjectPaths:FolderNotFound', '%s のフォルダが存在しません: %s', argName, folder);
end
% dir の '.' エントリの folder フィールドは '..' を解決済みの絶対パスになる
d = dir(folder);
idx = find(strcmp({d.name}, '.'), 1);
if isempty(idx)
    error('SetupProjectPaths:FolderNotResolvable', '%s を正規化できません: %s', argName, folder);
end
out = d(idx).folder;
end

% =========================================================================
function folders = CollectCodeFolders(rootDir, includeRoot, excludeFolders)
% rootDir 以下から「path に載せる価値があるフォルダ」を列挙する
%   - .m を含むフォルダのみ（データ置き場を path に載せない = .mat の誤解決も防ぐ）
%   - excludeFolders に一致する名前のフォルダとその配下は除外
%   - includeRoot=true なら rootDir 自身は .m の有無に関わらず含める
candidates = SplitPathList(genpath(rootDir));   % genpath は . / @ / + / private を自動で除外

isExcluded = cellfun(@(f) HasExcludedComponent(f, rootDir, excludeFolders), candidates);
candidates = candidates(~isExcluded);

isRoot   = strcmp(NormalizeForCompare(candidates), NormalizeForCompare({rootDir}));
hasCode  = cellfun(@(f) ~isempty(dir(fullfile(f, '*.m'))), candidates);
if includeRoot
    keepMask = hasCode | isRoot;
else
    % 依存先のルート直下（Params.m・Proc*.m 等）は当該実験を隠すため載せない
    keepMask = hasCode & ~isRoot;
end

folders = UniqueStable(candidates(keepMask));
end

% =========================================================================
function tf = HasExcludedComponent(folder, rootDir, excludeFolders)
% rootDir から見た相対パスの各要素が除外名に一致するかを判定する
if isempty(excludeFolders)
    tf = false;
    return
end
relative = extractAfter(NormalizeForCompare({folder}), NormalizeForCompare({rootDir}));
parts    = SplitFolderParts(relative{1});
tf       = any(ismember(parts, lower(excludeFolders)));
end

% =========================================================================
function parts = SplitFolderParts(relativePath)
% パス区切り（\ と /）でフォルダ名要素に分解する（空要素は除去）
parts = strsplit(relativePath, {'\', '/'});
parts = parts(~cellfun(@isempty, parts));
end

% =========================================================================
function tf = IsUnderExperimentRoots(entry)
% path エントリが Projects または Sample フォルダ（またはその配下）かを判定する
key = NormalizeForCompare({entry});
key = key{1};
tf  = contains(key, [filesep 'projects' filesep]) || endsWith(key, [filesep 'projects']) ...
   || contains(key, [filesep 'sample' filesep])   || endsWith(key, [filesep 'sample']);
end

% =========================================================================
function list = SplitPathList(pathString)
% pathsep 区切り文字列を cellstr へ（空要素・末尾区切りを除去）
list = strsplit(pathString, pathsep);
list = list(~cellfun(@isempty, list));
list = cellfun(@(p) char(p), list, 'UniformOutput', false);
end

% =========================================================================
function keys = NormalizeForCompare(folders)
% パス比較用キー（小文字化・区切り統一・末尾区切り除去）
keys = cellfun(@NormalizeOne, folders, 'UniformOutput', false);
end

% =========================================================================
function key = NormalizeOne(folder)
key = lower(strrep(char(folder), '/', filesep));
key = strrep(key, '\', filesep);
if numel(key) > 1 && strcmp(key(end), filesep)
    key = key(1:end - 1);
end
end

% =========================================================================
function out = UniqueStable(list)
% 出現順を保った重複排除（path の優先順を壊さないため sort しない）
if isempty(list)
    out = {};
    return
end
[~, idx] = unique(NormalizeForCompare(list), 'stable');   % idx は初出順（昇順）
out = list(idx);
end

% =========================================================================
function out = ToCellStr(value)
% char / string / cell を cellstr へ正規化
if isempty(value)
    out = {};
elseif ischar(value)
    out = {value};
elseif isstring(value)
    out = cellstr(value(:).');
else
    out = cellfun(@char, value(:).', 'UniformOutput', false);
end
end
