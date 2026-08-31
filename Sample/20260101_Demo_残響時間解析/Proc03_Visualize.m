% Proc03_Visualize - 減衰曲線・スペクトログラムの図出力 -> Export/*.png + manifest.json
%
% 図の契約どおり ApplyFigureStyle -> ExportFigure -> WriteExportManifest で出す。

%% パス設定
thisDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisDir, '..', '..', 'Functions', 'Core'));
SetupProjectPaths(thisDir);
params = Params();

%% 前段の読み込み
prepared = LoadCacheMat(fullfile(thisDir, 'Cache', 'Proc01', 'prepared.mat'));
reverbCachePath = fullfile(thisDir, 'Cache', 'Proc02', 'reverb.mat');
if ~isfile(reverbCachePath)
    error('Proc03:NoInput', '前段の出力がありません。先に Proc02_EstimateRT を実行してください。');
end
analyzed = LoadCacheMat(reverbCachePath);

exportDir = fullfile(thisDir, 'Export');
exportedPaths = {};

%% 図1: エネルギー減衰曲線 + 推定T60
reverb = analyzed.data.reverb;
fig = figure('Visible', 'off');
plot(reverb.timeSec, reverb.decayCurveDb);
hold on;
% 理想の減衰直線 (正解T60): 0 dB から -60 dB/T60 の傾き
idealLine = -60 / params.t60TrueSec * reverb.timeSec;
plot(reverb.timeSec, idealLine, '--');
hold off;
ylim([-80 5]);
xlabel('時間 [s]');
ylabel('エネルギー減衰 [dB]');
legend({sprintf('測定EDC (T30推定: %.2f s)', reverb.t60FromT30), ...
    sprintf('理想減衰 (正解: %.2f s)', params.t60TrueSec)}, 'Location', 'northeast');
grid on;
ApplyFigureStyle(fig, params.figPreset);
exportedPaths = [exportedPaths, ...
    ExportFigure(fig, exportDir, 'decay_curve', 'Preset', params.figPreset)];
close(fig);

%% 図2: IRのスペクトログラム
spec = ComputeSpectrogram(prepared.data.ir, prepared.data.fs, 'FrameSize', 2048);
fig = figure('Visible', 'off');
imagesc(spec.timeSec, spec.freqHz, spec.powerDb);
axis xy;
colormap(GetColorPalette('sequential'));
colorbarHandle = colorbar;
colorbarHandle.Label.String = 'パワー [dB]';
clim([max(spec.powerDb(:)) - 80, max(spec.powerDb(:))]);
xlabel('時間 [s]');
ylabel('周波数 [Hz]');
ApplyFigureStyle(fig, params.figPreset);
exportedPaths = [exportedPaths, ...
    ExportFigure(fig, exportDir, 'spectrogram', 'Preset', params.figPreset)];
close(fig);

%% manifest (図とパラメータの対応記録)
manifestPath = WriteExportManifest(exportDir, params, exportedPaths);
fprintf('Proc03: 図%d枚を出力しました -> %s\n', numel(exportedPaths), manifestPath);
