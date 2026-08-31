function RunAllChecks(extraCheckDirs)
% RunAllChecks - リポジトリ検証の単一入口（checkcode一括 + runtests一括）
%
% AI・CI・人間が同じ1コマンドで「安全に進めてよいか」を判定できるようにするための
% 総合チェッカー。以下2段階を順に実行し、いずれかが失敗したら error() を投げる
% （matlab -batch はエラー発生時に exit code 非0で終了する契約）。
%
%   1) checkcode 一括判定: Functions/ + Tests/ + Sample/ + Projects/_template/ の
%      全 .m ファイルに checkcode を実行し、警告が1件でもあれば失敗
%      （ファイル名・行・メッセージを一覧表示）
%   2) runtests('Tests', 'IncludeSubfolders', true) を実行し、
%      1件でも失敗（Failed/Incomplete）があれば失敗
%
% 通常は `matlab -batch "buildtool"` を使う。本関数は buildtool が使えない環境の
% フォールバック入口、および実験フォルダを対象に加えたいときの入口。
%
% 入力:
%   extraCheckDirs - checkcode対象に追加するディレクトリのcell配列（絶対/相対パス）
%                    （オプション、既定: 空セル）。実験（Projects配下）の
%                    checkcodeを行いたい場合にここへ渡す。
%
% 使用例:
%   matlab -batch "addpath('Tests/tools'); RunAllChecks"
%   matlab -batch "addpath('Tests/tools'); RunAllChecks({'Projects/20260915_残響測定'})"

arguments
    extraCheckDirs (1, :) cell = {}
end

% リポジトリルート（このファイルは Tests/tools/ 直下に配置される想定）
toolsDir = fileparts(mfilename('fullpath'));
testsDir = fileparts(toolsDir);
repoRoot = fileparts(testsDir);

functionsDir = fullfile(repoRoot, 'Functions');
sampleDir    = fullfile(repoRoot, 'Sample');
templateDir  = fullfile(repoRoot, 'Projects', '_template');

% checkcode対象ディレクトリ（既定: Functions + Tests + Sample + _template）
checkDirs = [{functionsDir, testsDir, sampleDir, templateDir}, extraCheckDirs];

fprintf('=== RunAllChecks: 開始 ===\n');

% -----------------------
% 1) checkcode 一括判定
% -----------------------
fprintf('--- [1/2] checkcode 一括判定 ---\n');
[checkFiles, checkIssues] = CollectCheckcodeIssues(checkDirs);

totalIssueNum = sum(cellfun(@numel, checkIssues));
if totalIssueNum > 0
    ReportCheckcodeIssues(checkFiles, checkIssues);
    error('RunAllChecks:CheckcodeWarnings', ...
        'checkcode警告が%d件見つかりました（対象ファイル数: %d）。上記一覧を修正してください。', ...
        totalIssueNum, numel(checkFiles));
end
fprintf('checkcode: 対象%dファイル、警告0件 -> PASS\n', numel(checkFiles));

% -----------------------
% 2) runtests('Tests') 一括実行
% -----------------------
fprintf('--- [2/2] runtests(''Tests'') ---\n');
testResults = runtests(testsDir, 'IncludeSubfolders', true);

if isempty(testResults)
    error('RunAllChecks:NoTests', ...
        'Tests/ 配下でテストが1件も見つかりませんでした。命名規約（*Test.m）を確認してください。');
end

disp(table(testResults));

failedMask = [testResults.Failed] | [testResults.Incomplete];
if any(failedMask)
    failedNames = {testResults(failedMask).Name};
    error('RunAllChecks:TestFailure', ...
        'テストが%d件失敗しました: %s', nnz(failedMask), strjoin(failedNames, ', '));
end
fprintf('runtests: %d件すべてPASS\n', numel(testResults));

fprintf('=== RunAllChecks: 総合PASS ===\n');

end

% =========================================================================
function [files, issues] = CollectCheckcodeIssues(checkDirs)
% CollectCheckcodeIssues - 指定ディレクトリ配下の全 .m ファイルに checkcode を実行する

numDirs = numel(checkDirs);
filesPerDir = cell(1, numDirs);

for dirIdx = 1:numDirs
    targetDir = checkDirs{dirIdx};
    if ~isfolder(targetDir)
        error('RunAllChecks:DirNotFound', 'checkcode対象ディレクトリが存在しません: %s', targetDir);
    end
    found = dir(fullfile(targetDir, '**', '*.m'));
    filesPerDir{dirIdx} = fullfile({found.folder}, {found.name});
end

files = unique([filesPerDir{:}]);
issues = cellfun(@(f) checkcode(f, '-struct'), files, 'UniformOutput', false);

end

% =========================================================================
function ReportCheckcodeIssues(files, issues)
% ReportCheckcodeIssues - checkcode警告の一覧をファイル名・行・メッセージで表示する

warnIdx = find(~cellfun(@isempty, issues));
for k = warnIdx
    fprintf('  %s\n', files{k});
    fileIssues = issues{k};
    for m = 1:numel(fileIssues)
        fprintf('    line %d: %s\n', fileIssues(m).line(1), fileIssues(m).message);
    end
end

end
