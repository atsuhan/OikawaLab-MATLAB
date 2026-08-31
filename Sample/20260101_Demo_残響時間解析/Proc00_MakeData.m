% Proc00_MakeData - 合成データの生成と波形の目視確認 (初回のみ手動実行)
%
% 残響時間が既知の合成インパルス応答を Input/demo_ir.wav へ生成し、
% 波形をプロットして「データがどんな形か」を目で確認する。

%% パス設定
thisDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisDir, '..', '..', 'Functions', 'Core'));
SetupProjectPaths(thisDir);
params = Params();

%% 合成データ生成
wavPath = MakeDemoInputWav(thisDir, params);
fprintf('Proc00: 合成IRを生成しました (正解T60 = %.2f s) -> %s\n', ...
    params.t60TrueSec, wavPath);

%% 波形の目視確認
[ir, fs] = LoadAudioFile(wavPath);
figure('Name', 'Proc00: 合成IRの波形');
timeSec = (0:numel(ir) - 1).' / fs;
plot(timeSec, ir);
xlabel('時間 [s]');
ylabel('振幅');
title('合成インパルス応答 (指数減衰 + ノイズフロア)');
ApplyFigureStyle(gcf, params.figPreset);
