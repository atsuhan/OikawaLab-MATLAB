% Proc03_Visualize - 図出力 -> Export/*.png + manifest.json
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
analysisCachePath = fullfile(thisDir, 'Cache', 'Proc02', 'spectrum.mat');
if ~isfile(analysisCachePath)
    error('Proc03:NoInput', '前段の出力がありません。先に Proc02_Analyze を実行してください。');
end
analyzed = LoadCacheMat(analysisCachePath);

%% スペクトル図 (ファイルごとに1枚)
exportDir = fullfile(thisDir, 'Export');
exportedPaths = {};
for k = 1:numel(analyzed.data.spectra)
    spectrum = analyzed.data.spectra{k};
    [~, baseName] = fileparts(analyzed.data.nameList{k});

    fig = figure('Visible', 'off');
    semilogx(spectrum.freqHz, 20 * log10(max(spectrum.amplitude, eps)));
    xlim(params.plotBandHz);
    xlabel('周波数 [Hz]');
    ylabel('振幅 [dB]');
    title(baseName, 'Interpreter', 'none');
    grid on;

    ApplyFigureStyle(fig, params.figPreset);
    newPaths = ExportFigure(fig, exportDir, ['spectrum_', baseName], ...
        'Preset', params.figPreset);
    exportedPaths = [exportedPaths, newPaths]; %#ok<AGROW> (件数は少数)
    close(fig);
end

%% manifest (図とパラメータの対応記録)
manifestPath = WriteExportManifest(exportDir, params, exportedPaths);
fprintf('Proc03: 図%d枚を出力しました -> %s\n', numel(exportedPaths), manifestPath);
