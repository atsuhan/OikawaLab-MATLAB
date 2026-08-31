function plan = buildfile
% buildfile - buildtool タスク定義（検証ゲートの主入口）
%
% 使い方:
%   matlab -batch "buildtool"          % 既定 = check + test
%   matlab -batch "buildtool check"    % 静的解析のみ（checkcode警告ゼロ）
%   matlab -batch "buildtool test"     % テストのみ
%   matlab -batch "buildtool index"    % docs/functions-reference.md を再生成

import matlab.buildtool.tasks.CodeIssuesTask

plan = buildplan(localfunctions);

checkTargets = [
    "Functions/**/*.m"
    "Tests/**/*.m"
    "Sample/**/*.m"
    "Projects/_template/**/*.m"
];
plan("check") = CodeIssuesTask(checkTargets, WarningThreshold = 0);

plan.DefaultTasks = ["check", "test"];
end

% =========================================================================
function testTask(~)
% Tests を実行する (Functions を path に載せてから runtests)
thisDir = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(thisDir, 'Functions')));
addpath(fullfile(thisDir, 'Tests', 'tools'));
results = runtests(fullfile(thisDir, 'Tests'), 'IncludeSubfolders', true);
disp(table(results));
assertSuccess(results);
end

% =========================================================================
function indexTask(~)
% 関数索引 docs/functions-reference.md を生成する
thisDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisDir, 'Tests', 'tools'));
GenFunctionsIndex();
end
