classdef FigureStyleTest < matlab.unittest.TestCase
    % FigureStyleTest - 図スタイル関数群 (プリセット/適用/書き出し) を検証する
    %
    % ヘッドレス (matlab -batch) でも同じ図が出ることが契約のため、
    % 全テストを 'Visible','off' の figure で行う。

    properties (Constant)
        PresetNames = {'paper-single', 'paper-double', 'slide', 'a4report'}
    end

    properties
        TempDir
    end

    methods (TestMethodSetup)
        function createTempDir(testCase)
            testCase.TempDir = tempname();
            mkdir(testCase.TempDir);
            testCase.addTeardown(@() rmdir(testCase.TempDir, 's'));
        end
    end

    methods (Test)

        function allPresetsHaveConsistentFields(testCase)
            % 全プリセットが必須フィールドを持ち、値が妥当なこと。
            requiredFields = {'name', 'widthCm', 'heightCm', 'fontSizePt', ...
                'fontName', 'lineWidth', 'axesLineWidth', 'tickDir', ...
                'boxOn', 'gridAlpha', 'colorOrder', 'exportDpi'};
            for k = 1:numel(testCase.PresetNames)
                preset = GetFigureStylePreset(testCase.PresetNames{k});
                for f = 1:numel(requiredFields)
                    testCase.verifyTrue(isfield(preset, requiredFields{f}), ...
                        sprintf('%s に %s がありません。', ...
                        testCase.PresetNames{k}, requiredFields{f}));
                end
                testCase.verifyGreaterThan(preset.widthCm, 0);
                testCase.verifyGreaterThan(preset.fontSizePt, 0);
                testCase.verifySize(preset.colorOrder, [8 3]);
            end
        end

        function unknownPresetThrowsIdentifiedError(testCase)
            testCase.verifyError(@() GetFigureStylePreset('nonexistent'), ...
                'GetFigureStylePreset:UnknownPreset');
        end

        function paletteValuesAreValidRgb(testCase)
            % 全パレットが [N x 3] の 0-1 RGB であること。
            names = {'okabe-ito', 'sequential', 'diverging'};
            for k = 1:numel(names)
                colors = GetColorPalette(names{k});
                testCase.verifyEqual(size(colors, 2), 3);
                testCase.verifyGreaterThanOrEqual(min(colors(:)), 0);
                testCase.verifyLessThanOrEqual(max(colors(:)), 1);
            end
            testCase.verifyError(@() GetColorPalette('nope'), ...
                'GetColorPalette:UnknownPalette');
        end

        function applyStyleSetsSizeAndFonts(testCase)
            % ApplyFigureStyle が figureサイズ(cm)とaxesフォントを設定すること。
            fig = figure('Visible', 'off');
            testCase.addTeardown(@() close(fig));
            plot(1:10, sin(1:10));

            preset = ApplyFigureStyle(fig, 'paper-single');

            originalUnits = fig.Units;
            fig.Units = 'centimeters';
            actualSize = fig.Position(3:4);
            fig.Units = originalUnits;
            testCase.verifyEqual(actualSize, ...
                [preset.widthCm, preset.heightCm], 'AbsTol', 0.05, ...
                'figureサイズがプリセットと一致しません。');

            ax = findall(fig, 'Type', 'axes');
            testCase.verifyEqual(ax(1).FontSize, preset.fontSizePt);
            lineObj = findall(fig, 'Type', 'line');
            testCase.verifyEqual(lineObj(1).LineWidth, preset.lineWidth);
        end

        function applyStyleAcceptsOverrides(testCase)
            % Name-Value での上書きが効くこと。
            fig = figure('Visible', 'off');
            testCase.addTeardown(@() close(fig));
            plot(1:5);

            preset = ApplyFigureStyle(fig, 'slide', 'FontSize', 20, 'WidthCm', 30);
            testCase.verifyEqual(preset.fontSizePt, 20);
            testCase.verifyEqual(preset.widthCm, 30);
        end

        function exportFigureWritesTimestampedPng(testCase)
            % ヘッドレスで PNG が生成され、命名規約に従うこと。
            fig = figure('Visible', 'off');
            testCase.addTeardown(@() close(fig));
            plot(1:10, cos(1:10));
            ApplyFigureStyle(fig, 'paper-single');

            paths = ExportFigure(fig, testCase.TempDir, 'demo_wave');

            testCase.verifyNumElements(paths, 1);
            testCase.verifyTrue(isfile(paths{1}), 'PNGが生成されていません。');
            [~, fileName, ext] = fileparts(paths{1});
            testCase.verifyEqual(ext, '.png');
            testCase.verifyMatches(fileName, '^demo_wave_\d{8}-\d{6}$', ...
                'ファイル名が <baseName>_<yyyyMMdd-HHmmss> 規約に従っていません。');

            info = dir(paths{1});
            testCase.verifyGreaterThan(info.bytes, 1000, 'PNGが空に近いサイズです。');
        end

        function exportFigureBothFormatWritesPngAndPdf(testCase)
            % Format='both' で PNG と PDF の両方が生成されること。
            fig = figure('Visible', 'off');
            testCase.addTeardown(@() close(fig));
            plot(1:10);
            ApplyFigureStyle(fig, 'paper-single');

            paths = ExportFigure(fig, testCase.TempDir, 'fig', 'Format', 'both');

            testCase.verifyNumElements(paths, 2);
            testCase.verifyTrue(endsWith(paths{1}, '.png'));
            testCase.verifyTrue(endsWith(paths{2}, '.pdf'));
            testCase.verifyTrue(isfile(paths{2}));
        end

    end
end
