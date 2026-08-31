function colors = GetColorPalette(paletteName)
% GetColorPalette - 研究室標準のカラーパレット [N x 3] RGB(0-1) を返す
%
% 既定の 'okabe-ito' は色覚多様性に配慮した8色 (Okabe & Ito, 2008)。
% 折れ線・カテゴリ分けはこれを使う。連続量には 'sequential'、
% 正負・差分の表示には 'diverging' を使う。
%
% 入力:
%   paletteName - 'okabe-ito' (既定) | 'sequential' | 'diverging'
% 出力:
%   colors - [N x 3] RGB (0-1)。okabe-ito は 8x3、他は 256x3
arguments
    paletteName {mustBeTextScalar} = 'okabe-ito'
end

switch lower(char(paletteName))
    case 'okabe-ito'
        colors = [
            0.000 0.447 0.698    % 青
            0.902 0.624 0.000    % 橙
            0.000 0.620 0.451    % 緑
            0.835 0.369 0.000    % 朱
            0.337 0.706 0.914    % 空色
            0.941 0.894 0.259    % 黄
            0.800 0.475 0.655    % 赤紫
            0.000 0.000 0.000    % 黒
        ];
    case 'sequential'
        % 白 -> 青の単調グラデーション (明度が単調なのでグレースケール印刷でも読める)
        anchor = [1.000 1.000 1.000; 0.337 0.706 0.914; 0.000 0.447 0.698; 0.031 0.188 0.420];
        colors = InterpolatePalette(anchor, 256);
    case 'diverging'
        % 青 -> 白 -> 朱 (正負対称。ゼロ中心の量に使う)
        anchor = [0.000 0.447 0.698; 1.000 1.000 1.000; 0.835 0.369 0.000];
        colors = InterpolatePalette(anchor, 256);
    otherwise
        error('GetColorPalette:UnknownPalette', ...
            '未知のパレット名です: %s (okabe-ito / sequential / diverging)', paletteName);
end
end

% =========================================================================
function colors = InterpolatePalette(anchorColors, numColors)
% アンカー色を等間隔で線形補間して numColors 色のマップを作る
anchorPos = linspace(0, 1, size(anchorColors, 1));
targetPos = linspace(0, 1, numColors);
colors = zeros(numColors, 3);
for ch = 1:3
    colors(:, ch) = interp1(anchorPos, anchorColors(:, ch), targetPos, 'linear').';
end
colors = min(max(colors, 0), 1);
end
