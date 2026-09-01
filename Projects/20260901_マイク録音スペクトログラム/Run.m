% Run - この実験の一気通貫実行 (Proc01 -> Proc03)
%
% 使い方:
%   MATLABでこの実験フォルダをカレントにして Run
%   ヘッドレス: matlab -batch "cd('Projects/YYYYMMDD_実験名'); Run"
%
% 規約 (docs/rules/project.md):
%   - Proc00 (目視確認) は Run に含めない。初回に手動実行する。
%   - パス設定は SetupProjectPaths のみ。addpath(genpath(...)) は使わない。

thisDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisDir, '..', '..', 'Functions', 'Core'));   % ブートストラップ
SetupProjectPaths(thisDir);

fprintf('=== Run: %s ===\n', thisDir);

Proc01_Prepare
Proc02_Analyze
Proc03_Visualize

fprintf('=== Run: 完了 (Export/ を確認) ===\n');
