% Proc01_Prepare - IR読み込み -> Cache/Proc01/prepared.mat
%
% 出力: Cache/Proc01/prepared.mat
%   data.ir      [N x 1] インパルス応答 (フルスケール±1)
%   data.fs      double  サンプリング周波数 [Hz]
%   data.wavName char    読み込んだファイル名

%% パス設定
thisDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisDir, '..', '..', 'Functions', 'Core'));
SetupProjectPaths(thisDir);
params = Params();

%% データがなければ自動生成 (デモ専用の挙動)
wavPath = fullfile(thisDir, 'Input', 'demo_ir.wav');
if ~isfile(wavPath)
    fprintf('Proc01: Input/ が空のため合成データを生成します。\n');
    wavPath = MakeDemoInputWav(thisDir, params);
end

%% 読み込み (合成条件が変わったら作り直して読み直す)
wavInfo = dir(wavPath);
prepareKey = HashArrays(params.fs, params.t60TrueSec, params.durationSec, ...
    params.noiseFloorDb, wavInfo.bytes);
cachePath = fullfile(thisDir, 'Cache', 'Proc01', 'prepared.mat');
prepared = RunCached(cachePath, prepareKey, ...
    @() PrepareIr(thisDir, params), 'forceRecalc', params.forceRecalc);

fprintf('Proc01: IRを準備しました (%.2f s @ %d Hz) -> %s\n', ...
    numel(prepared.ir) / prepared.fs, prepared.fs, cachePath);

%% ---- ローカル関数 ----
function data = PrepareIr(projectDir, params)
% 合成条件に合ったIRを (必要なら作り直して) 読み込む
wavPath = MakeDemoInputWav(projectDir, params);
[ir, fs] = LoadAudioFile(wavPath);
[~, name, ext] = fileparts(wavPath);
data = struct('ir', ir(:, 1), 'fs', fs, 'wavName', [name, ext]);
end
