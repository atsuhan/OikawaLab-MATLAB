% Run - デモ実験の一気通貫実行 (Proc01 -> Proc03)
%
% 使い方:
%   MATLABでこのフォルダをカレントにして Run
%   ヘッドレス: matlab -batch "cd('Sample/20260101_Demo_残響時間解析'); Run"
%
% Input/ にデータがない場合は Proc01 が自動生成する (デモ専用の挙動。
% 実データを扱う実験では Proc00 で目視確認してから進むこと)。

thisDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisDir, '..', '..', 'Functions', 'Core'));   % ブートストラップ
SetupProjectPaths(thisDir);

fprintf('=== Run: 残響時間解析デモ ===\n');

Proc01_Prepare
Proc02_EstimateRT
Proc03_Visualize

fprintf('=== Run: 完了 (Export/ を確認) ===\n');
