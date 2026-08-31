function [data, info] = RunCached(matPath, inputHash, computeFcn, opts)
% RunCached - 入力ハッシュが一致すればキャッシュを返し、なければ計算して保存する
%
% Proc スクリプトの再計算を最小化する中核関数。「出力を実際に決定する入力すべて」を
% HashArrays でハッシュ化して渡すこと。入力が変わればハッシュが変わり、自動で
% 再計算される (古いキャッシュが黙って混ざる事故を防ぐ)。
%
% 使い方 (Proc スクリプト内):
%   key = HashArrays(irData, fs, params.bandFreqsHz);
%   result = RunCached(fullfile(cacheDir, 'decay.mat'), key, ...
%       @() ComputeDecay(irData, fs, params));
%
% 入力:
%   matPath    - キャッシュ .mat パス (Cache/Proc<NN>/<名前>.mat)
%   inputHash  - 1x64 char (HashArrays の戻り値)
%   computeFcn - 引数なしで計算結果 struct を返す function handle
%   opts.forceRecalc - true でキャッシュを無視して再計算 (既定: false)
%   opts.verbose     - キャッシュ利用/再計算を表示 (既定: true)
% 出力:
%   data - 計算結果 struct (キャッシュヒット時は保存済みのもの)
%   info.fromCache - logical キャッシュを使ったか
%   info.matPath   - char   キャッシュファイルパス
arguments
    matPath {mustBeTextScalar}
    inputHash (1, 64) char
    computeFcn (1, 1) function_handle
    opts.forceRecalc (1, 1) logical = false
    opts.verbose (1, 1) logical = true
end

matPath = char(matPath);
[~, cacheName] = fileparts(matPath);

if ~opts.forceRecalc && isfile(matPath)
    cached = TryLoadCache(matPath);
    if ~isempty(cached) && strcmp(cached.inputHash, inputHash)
        data = cached.data;
        info = struct('fromCache', true, 'matPath', matPath);
        if opts.verbose
            fprintf('RunCached: キャッシュ利用 %s\n', cacheName);
        end
        return
    end
end

if opts.verbose
    fprintf('RunCached: 計算中 %s ...\n', cacheName);
end
data = computeFcn();
if ~(isstruct(data) && isscalar(data))
    error('RunCached:BadComputeResult', ...
        'computeFcn は 1x1 struct を返してください (実際: %s)。', class(data));
end
SaveCacheMat(matPath, data, inputHash);
info = struct('fromCache', false, 'matPath', matPath);
end

% =========================================================================
function cached = TryLoadCache(matPath)
% 壊れたキャッシュは「なかったこと」にして再計算へ回す
try
    cached = LoadCacheMat(matPath);
catch
    cached = [];
end
end
