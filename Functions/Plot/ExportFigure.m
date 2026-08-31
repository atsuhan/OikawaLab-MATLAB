function exportedPaths = ExportFigure(fig, exportDir, baseName, opts)
% ExportFigure - 図をタイムスタンプ付きで Export フォルダへ書き出す
%
% 作図の標準3ステップの3番目。exportgraphics のラッパーで、
%   - ファイル名 <baseName>_<yyyyMMdd-HHmmss>.png (+ 任意で .pdf ベクタ)
%   - R2025a以降は Width 指定で物理幅を固定 (全図のフォントサイズが揃う)
%   - 戻り値をそのまま WriteExportManifest へ渡せる
% を提供する。saveas / print / 生の exportgraphics を直接使わないこと。
%
% 入力:
%   fig       - figureハンドル (ApplyFigureStyle 適用済みであること)
%   exportDir - 出力フォルダ (なければ作成)
%   baseName  - ファイル名の先頭部 (例: 'decay_curve')
%   opts.Preset     - サイズ・DPIの参照プリセット (既定: 'paper-single')
%   opts.Format     - 'png' (既定) | 'pdf' | 'both'
%   opts.Resolution - ラスタ解像度 [dpi] (既定: プリセットの exportDpi)
% 出力:
%   exportedPaths - 生成したファイルの絶対パス cellstr
arguments
    fig (1, 1) matlab.ui.Figure
    exportDir {mustBeTextScalar}
    baseName {mustBeTextScalar}
    opts.Preset {mustBeTextScalar} = 'paper-single'
    opts.Format {mustBeMember(opts.Format, {'png', 'pdf', 'both'})} = 'png'
    opts.Resolution (1, 1) double = NaN
end

preset = GetFigureStylePreset(opts.Preset);
if isnan(opts.Resolution)
    opts.Resolution = preset.exportDpi;
end

exportDir = EnsureFolder(exportDir);
stem = fullfile(exportDir, sprintf('%s_%s', char(baseName), TimestampString()));

% R2025a 以降は Width/Units 指定で出力の物理幅を固定できる (フォント統一の決め手)。
% それ未満は ApplyFigureStyle が設定した figure サイズに任せる。
supportsWidthOption = ~isMATLABReleaseOlderThan('R2025a');

exportedPaths = {};
if any(strcmp(opts.Format, {'png', 'both'}))
    pngPath = [stem, '.png'];
    if supportsWidthOption
        exportgraphics(fig, pngPath, 'Resolution', opts.Resolution, ...
            'Width', preset.widthCm, 'Units', 'centimeters');
    else
        exportgraphics(fig, pngPath, 'Resolution', opts.Resolution);
    end
    exportedPaths{end + 1} = pngPath; %#ok<AGROW>
end

if any(strcmp(opts.Format, {'pdf', 'both'}))
    pdfPath = [stem, '.pdf'];
    if supportsWidthOption
        exportgraphics(fig, pdfPath, 'ContentType', 'vector', ...
            'Width', preset.widthCm, 'Units', 'centimeters');
    else
        exportgraphics(fig, pdfPath, 'ContentType', 'vector');
    end
    exportedPaths{end + 1} = pdfPath; %#ok<AGROW>
end
end
