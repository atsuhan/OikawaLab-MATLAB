function params = Params()
% Params - この実験のパラメータ (1ファイル完結の単一正本)
%
% 実験に関する「決め」はすべてここに書く。Procスクリプト内に数値を
% 直書きしない。値を変えたら Run を再実行する (キャッシュは自動で無効化される)。

params = struct();

% --- 計測条件 (READMEの測定条件と一致させる) ---
params.expectedFs = 48000;          % 期待サンプリング周波数 [Hz] (不一致なら警告)
params.calibrationPaPerUnit = NaN;  % 校正係数 [Pa/FS]。未校正なら NaN (±1のまま扱う)

% --- 解析設定 ---
params.windowType = 'hann';         % スペクトル解析の窓
params.plotBandHz = [20 20000];     % 図の周波数表示範囲 [Hz]

% --- 図 ---
params.figPreset = 'paper-single';  % 図スタイルプリセット (docs/rules/project.md 参照)

% --- キャッシュ ---
params.forceRecalc = false;         % true で全段を強制再計算
end
