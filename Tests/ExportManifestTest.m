classdef ExportManifestTest < matlab.unittest.TestCase
    % ExportManifestTest - WriteExportManifest のスキーマとハッシュ再現性を検証する

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

        function manifestHasRequiredFields(testCase)
            % manifest.json が generatedAt / paramsHash / images を持つこと。
            params = struct('fs', 48000, 'method', 'demo');
            imagePath = fullfile(testCase.TempDir, 'fig_20260101-000000.png');
            fclose(fopen(imagePath, 'w'));

            manifestPath = WriteExportManifest(testCase.TempDir, params, {imagePath});
            manifest = jsondecode(fileread(manifestPath));

            testCase.verifyTrue(isfield(manifest, 'generatedAt'));
            testCase.verifyTrue(isfield(manifest, 'paramsHash'));
            testCase.verifyTrue(startsWith(manifest.paramsHash, 'sha256:'));
            testCase.verifyEqual(numel(manifest.paramsHash), 7 + 64);
            testCase.verifyEqual(cellstr(manifest.images), {'fig_20260101-000000.png'}, ...
                'Export相対パス(/区切り)で記録されるべき。');
        end

        function paramsHashIsReproducibleAndFieldOrderInsensitive(testCase)
            % 同じParamsなら (フィールド定義順が違っても) 同じ paramsHash になること。
            paramsA = struct('fs', 48000, 'gain', 1.5);
            paramsB = struct('gain', 1.5, 'fs', 48000);   % 定義順だけ違う

            pathA = WriteExportManifest(fullfile(testCase.TempDir, 'a'), paramsA);
            pathB = WriteExportManifest(fullfile(testCase.TempDir, 'b'), paramsB);
            manifestA = jsondecode(fileread(pathA));
            manifestB = jsondecode(fileread(pathB));

            testCase.verifyEqual(manifestA.paramsHash, manifestB.paramsHash, ...
                'フィールド順への依存はorderfieldsで排除されるべき。');
        end

        function differentParamsGiveDifferentHash(testCase)
            % パラメータが変われば paramsHash も変わること (図の出所追跡の根幹)。
            pathA = WriteExportManifest(fullfile(testCase.TempDir, 'a'), struct('fs', 48000));
            pathB = WriteExportManifest(fullfile(testCase.TempDir, 'b'), struct('fs', 44100));
            manifestA = jsondecode(fileread(pathA));
            manifestB = jsondecode(fileread(pathB));

            testCase.verifyNotEqual(manifestA.paramsHash, manifestB.paramsHash);
        end

        function missingExportDirIsCreated(testCase)
            % Export フォルダがなければ作成されること。
            newDir = fullfile(testCase.TempDir, 'NewExport');
            manifestPath = WriteExportManifest(newDir, struct('x', 1));
            testCase.verifyTrue(isfile(manifestPath));
        end

    end
end
