function outputPath = GenFunctionsIndex(outputPath)
% GenFunctionsIndex - Functions配下のH1行からMarkdown関数索引を生成する
%
% 各関数のfunction宣言直後のコメントをH1として読み取り、
% docs/functions-reference.md をカテゴリ別テーブルで生成する。
% H1がない関数が1件でもあればエラーとし、不完全な索引を生成しない。
%
% 使用例:
%   matlab -batch "buildtool index"

toolsDir = fileparts(mfilename('fullpath'));
testsDir = fileparts(toolsDir);
repoRoot = fileparts(testsDir);
functionsDir = fullfile(repoRoot, 'Functions');

if nargin < 1 || strlength(string(outputPath)) == 0
    outputPath = fullfile(repoRoot, 'docs', 'functions-reference.md');
end
outputPath = char(outputPath);

files = dir(fullfile(functionsDir, '**', '*.m'));
relativePaths = arrayfun(@(item) RelativePath(item, functionsDir), files, ...
    'UniformOutput', false);
[relativePaths, order] = sort(relativePaths);
files = files(order);

entries = repmat(struct('name', '', 'category', '', 'summary', '', 'path', ''), ...
    numel(files), 1);
missingHeaders = strings(0, 1);

for fileIdx = 1:numel(files)
    fullPath = fullfile(files(fileIdx).folder, files(fileIdx).name);
    [~, functionName] = fileparts(files(fileIdx).name);
    summary = ReadH1(fullPath, functionName);
    if strlength(summary) == 0
        missingHeaders(end + 1, 1) = string(relativePaths{fileIdx}); %#ok<AGROW>
    end

    pathParts = split(string(relativePaths{fileIdx}), filesep);
    entries(fileIdx).name = functionName;
    entries(fileIdx).category = char(pathParts(1));
    entries(fileIdx).summary = char(summary);
    entries(fileIdx).path = strrep(relativePaths{fileIdx}, filesep, '/');
end

if ~isempty(missingHeaders)
    error('GenFunctionsIndex:MissingHeader', ...
        'H1行がないFunctions関数があります:%s%s', newline, ...
        strjoin(missingHeaders, newline));
end

lines = [
    "# Functions Reference"
    ""
    "> このファイルは `Tests/tools/GenFunctionsIndex.m` により生成されます。直接編集しないでください。"
    ""
    sprintf("Functions配下の関数: %d件 / H1欠落: 0件", numel(entries))
    ""
];

categories = unique(string({entries.category}), 'stable');
for categoryIdx = 1:numel(categories)
    category = categories(categoryIdx);
    lines(end + 1, 1) = "## " + category; %#ok<AGROW>
    lines(end + 1, 1) = ""; %#ok<AGROW>
    lines(end + 1, 1) = "| Function | Summary | Source |"; %#ok<AGROW>
    lines(end + 1, 1) = "|---|---|---|"; %#ok<AGROW>

    categoryEntries = entries(strcmp({entries.category}, category));
    for entryIdx = 1:numel(categoryEntries)
        entry = categoryEntries(entryIdx);
        summary = EscapeTableCell(entry.summary);
        source = "../Functions/" + string(entry.path);
        lines(end + 1, 1) = sprintf("| `%s` | %s | [source](%s) |", ...
            entry.name, summary, source); %#ok<AGROW>
    end
    lines(end + 1, 1) = ""; %#ok<AGROW>
end

outputDir = fileparts(outputPath);
if ~isfolder(outputDir)
    mkdir(outputDir);
end
fileId = fopen(outputPath, 'w', 'n', 'UTF-8');
if fileId < 0
    error('GenFunctionsIndex:OpenFailed', '出力ファイルを開けません: %s', outputPath);
end
cleanup = onCleanup(@() fclose(fileId));
fprintf(fileId, '%s\n', strjoin(lines, newline));

fprintf('Functions索引を生成しました: %s（%d関数、H1欠落0）\n', ...
    outputPath, numel(entries));
end

% =========================================================================
function relativePath = RelativePath(item, functionsDir)
% RelativePath - dir要素からFunctions相対パスを返す

fullPath = fullfile(item.folder, item.name);
prefix = [functionsDir, filesep];
relativePath = extractAfter(fullPath, strlength(prefix));
relativePath = char(relativePath);
end

% =========================================================================
function summary = ReadH1(filePath, functionName)
% ReadH1 - function宣言直後のコメントブロックからH1概要を抽出する

lines = splitlines(string(fileread(filePath)));
declarationIdx = find(startsWith(strtrim(lines), "function "), 1);
if isempty(declarationIdx)
    summary = "";
    return;
end

fallback = "";
for lineIdx = declarationIdx + 1:numel(lines)
    line = strtrim(lines(lineIdx));
    if strlength(line) == 0
        continue;
    end
    if ~startsWith(line, "%")
        break;
    end

    comment = strtrim(extractAfter(line, 1));
    if strlength(comment) == 0
        continue;
    end
    if strlength(fallback) == 0
        fallback = comment;
    end

    namePrefix = regexpPattern("^" + regexptranslate('escape', functionName));
    if startsWith(comment, functionName, 'IgnoreCase', true)
        remainder = strtrim(erase(comment, namePrefix));
        remainder = regexprep(remainder, '^[-—:：\s]+', '');
        if strlength(remainder) > 0
            summary = remainder;
            return;
        end
        continue;
    end

    summary = comment;
    return;
end

if strcmpi(fallback, functionName)
    summary = "";
else
    summary = fallback;
end
end

% =========================================================================
function escaped = EscapeTableCell(value)
% EscapeTableCell - Markdown表を壊す文字をエスケープする

escaped = replace(string(value), "|", "\|");
end
