function preset = ApplyFigureStyle(target, presetName, opts)
% ApplyFigureStyle - 図全体に研究室標準スタイルを一括適用する
%
% 作図の標準3ステップの2番目:
%   plot(t, x);
%   ApplyFigureStyle(gcf, 'paper-single');
%   ExportFigure(gcf, exportDir, 'waveform');
%
% figureサイズ(cm)、全axesのフォント・線幅・TickDir・Box・Grid・ColorOrder、
% 既存Lineオブジェクトの線幅をプリセットに揃える。
% `set(gca,'FontSize',...)` 等の手動調整はせず、微調整は本関数の
% Name-Value (FontSize= 等) で行うこと (docs/rules/project.md 図の契約)。
%
% 入力:
%   target     - figure または axes ハンドル (axesならその親figureに適用)
%   presetName - 'paper-single' | 'paper-double' | 'slide' | 'a4report'
%   opts.FontSize  - フォントサイズ上書き [pt]
%   opts.WidthCm   - 図の幅上書き [cm]
%   opts.HeightCm  - 図の高さ上書き [cm]
%   opts.LineWidth - プロット線幅上書き [pt]
% 出力:
%   preset - 適用したプリセット struct (上書き反映済み)
arguments
    target (1, 1) {mustBeA(target, 'handle')}
    presetName {mustBeTextScalar} = 'paper-single'
    opts.FontSize (1, 1) double = NaN
    opts.WidthCm (1, 1) double = NaN
    opts.HeightCm (1, 1) double = NaN
    opts.LineWidth (1, 1) double = NaN
end

preset = GetFigureStylePreset(presetName);
if ~isnan(opts.FontSize),  preset.fontSizePt = opts.FontSize;  end
if ~isnan(opts.WidthCm),   preset.widthCm    = opts.WidthCm;   end
if ~isnan(opts.HeightCm),  preset.heightCm   = opts.HeightCm;  end
if ~isnan(opts.LineWidth), preset.lineWidth  = opts.LineWidth; end

fig = ResolveFigure(target);

% ---- figureサイズ (画面上の位置は保ち、サイズだけcmで固定) ----
originalUnits = fig.Units;
fig.Units = 'centimeters';
fig.Position(3:4) = [preset.widthCm, preset.heightCm];
fig.Units = originalUnits;
fig.Color = 'w';

% ---- 全axesへスタイル適用 ----
axesList = findall(fig, 'Type', 'axes');
for k = 1:numel(axesList)
    ax = axesList(k);
    ax.FontName   = preset.fontName;
    ax.FontSize   = preset.fontSizePt;
    ax.LineWidth  = preset.axesLineWidth;
    ax.TickDir    = preset.tickDir;
    ax.GridAlpha  = preset.gridAlpha;
    ax.ColorOrder = preset.colorOrder;
    if preset.boxOn
        ax.Box = 'on';
    else
        ax.Box = 'off';
    end
end

% ---- 既存プロット線の線幅を揃える ----
lineList = findall(fig, 'Type', 'line');
for k = 1:numel(lineList)
    lineList(k).LineWidth = preset.lineWidth;
end

% ---- 凡例・カラーバー等のフォントも揃える ----
textTargets = findall(fig, '-property', 'FontName');
for k = 1:numel(textTargets)
    textTargets(k).FontName = preset.fontName;
end
end

% =========================================================================
function fig = ResolveFigure(target)
% figure/axes どちらを渡されても親figureを返す
if isa(target, 'matlab.ui.Figure')
    fig = target;
else
    fig = ancestor(target, 'figure');
    if isempty(fig)
        error('ApplyFigureStyle:NoFigure', ...
            'figureに属さないハンドルが渡されました: %s', class(target));
    end
end
end
