function preset = GetFigureStylePreset(presetName)
% GetFigureStylePreset - 図スタイルプリセット定義の単一正本
%
% 「誰が作っても論文・スライド品質の図」を実現するためのスタイル定義。
% ApplyFigureStyle / ExportFigure から参照される。数値を変えたいときは
% 呼び出し側で上書きせず、まずこのファイルの変更を検討する(全図に効くため)。
%
% プリセット:
%   'paper-single' - 論文1段組   幅 8.5cm x 高 6.5cm, 8pt
%   'paper-double' - 論文2段組   幅17.5cm x 高 8.0cm, 8pt
%   'slide'        - スライド16:9 幅24.0cm x 高13.5cm, 16pt
%   'a4report'     - A4レポート  幅15.0cm x 高 9.0cm, 10.5pt
%
% 入力:
%   presetName - 上記いずれか (char/string)
% 出力:
%   preset.name         char    プリセット名
%   preset.widthCm      double  図の幅 [cm]
%   preset.heightCm     double  図の高さ [cm]
%   preset.fontSizePt   double  基本フォントサイズ [pt]
%   preset.fontName     char    フォント (OS別に日本語対応フォントを自動選択)
%   preset.lineWidth    double  プロット線幅 [pt]
%   preset.axesLineWidth double 軸線幅 [pt]
%   preset.tickDir      char    'out'
%   preset.boxOn        logical 軸の箱を描くか
%   preset.gridAlpha    double  グリッド透明度
%   preset.colorOrder   [8 x 3] カラーパレット (okabe-ito)
%   preset.exportDpi    double  ラスタ出力解像度 [dpi]
arguments
    presetName {mustBeTextScalar}
end

presetName = lower(char(presetName));

% 共通既定値
preset = struct();
preset.name          = presetName;
preset.fontName      = SelectFontName();
preset.lineWidth     = 1.2;
preset.axesLineWidth = 0.8;
preset.tickDir       = 'out';
preset.boxOn         = true;
preset.gridAlpha     = 0.15;
preset.colorOrder    = GetColorPalette('okabe-ito');
preset.exportDpi     = 300;

switch presetName
    case 'paper-single'
        preset.widthCm    = 8.5;
        preset.heightCm   = 6.5;
        preset.fontSizePt = 8;
    case 'paper-double'
        preset.widthCm    = 17.5;
        preset.heightCm   = 8.0;
        preset.fontSizePt = 8;
    case 'slide'
        preset.widthCm    = 24.0;
        preset.heightCm   = 13.5;
        preset.fontSizePt = 16;
        preset.lineWidth  = 2.0;
    case 'a4report'
        preset.widthCm    = 15.0;
        preset.heightCm   = 9.0;
        preset.fontSizePt = 10.5;
    otherwise
        error('GetFigureStylePreset:UnknownPreset', ...
            '未知のプリセットです: %s (paper-single / paper-double / slide / a4report)', ...
            presetName);
end
end

% =========================================================================
function fontName = SelectFontName()
% OS別に日本語ラベルも表示できるフォントを選ぶ (存在しなければ既定にフォールバック)
persistent cachedFontName
if ~isempty(cachedFontName)
    fontName = cachedFontName;
    return
end

if ispc
    candidates = {'Yu Gothic UI', 'Meiryo', 'Arial'};
elseif ismac
    candidates = {'Hiragino Sans', 'Helvetica'};
else
    candidates = {'Noto Sans CJK JP', 'DejaVu Sans'};
end

available = listfonts();
fontName = '';
for k = 1:numel(candidates)
    if any(strcmpi(available, candidates{k}))
        fontName = candidates{k};
        break
    end
end
if isempty(fontName)
    fontName = get(groot, 'defaultAxesFontName');
end
cachedFontName = fontName;
end
