% Proc03_Visualize - スペクトログラム図出力 -> Export/*.png + manifest.json
%
% 解析結果を共通スタイルで図にする。図は必ず
% ApplyFigureStyle -> ExportFigure -> WriteExportManifest の3点セットで出す
% (docs/rules/project.md 図の契約)。

%% パス設定
thisDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisDir, '..', '..', 'Functions', 'Core'));
SetupProjectPaths(thisDir);
params = Params();

%% 前段の読み込み
analysisCachePath = fullfile(thisDir, 'Cache', 'Proc02', 'spectrogram.mat');
if ~isfile(analysisCachePath)
    error('Proc03:NoInput', '前段の出力がありません。先に Proc02_Analyze を実行してください。');
end
analyzed = LoadCacheMat(analysisCachePath);

%% スペクトログラム図 (録音ごとに1枚)
exportDir = fullfile(thisDir, 'Export');
exportedPaths = {};
for k = 1:numel(analyzed.data.spectrograms)
    spec = analyzed.data.spectrograms{k};
    [~, baseName] = fileparts(analyzed.data.nameList{k});

    fig = figure('Visible', 'off');
    imagesc(spec.timeSec, spec.freqHz, spec.powerDb);
    axis xy;
    colormap(GetColorPalette('sequential'));
    maxDb = max(spec.powerDb(:));
    clim([maxDb - params.dynamicRangeDb, maxDb]);
    ylim([max(params.plotBandHz(1), spec.freqHz(1)), ...
        min(params.plotBandHz(2), spec.freqHz(end))]);
    colorBar = colorbar;
    colorBar.Label.String = 'パワー [dB]';
    xlabel('時間 [s]');
    ylabel('周波数 [Hz]');
    title(baseName, 'Interpreter', 'none');

    ApplyFigureStyle(fig, params.figPreset);
    newPaths = ExportFigure(fig, exportDir, ['spectrogram_', baseName], ...
        'Preset', params.figPreset);
    exportedPaths = [exportedPaths, newPaths]; %#ok<AGROW> (件数は少数)
    close(fig);
end

%% manifest (図とパラメータの対応記録)
manifestPath = WriteExportManifest(exportDir, params, exportedPaths);
fprintf('Proc03: 図%d枚を出力しました -> %s\n', numel(exportedPaths), manifestPath);
