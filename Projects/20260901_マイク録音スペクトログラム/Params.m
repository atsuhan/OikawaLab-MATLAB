function params = Params()
% Params - この実験のパラメータ (1ファイル完結の単一正本)
%
% 実験に関する「決め」はすべてここに書く。Procスクリプト内に数値を
% 直書きしない。値を変えたら Run を再実行する (キャッシュは自動で無効化される)。

params = struct();

% --- 計測条件 (READMEの測定条件と一致させる) ---
params.expectedFs = 48000;          % 期待サンプリング周波数 [Hz] (不一致なら警告)
params.calibrationPaPerUnit = NaN;  % 校正係数 [Pa/FS]。未校正なら NaN (±1のまま扱う)

% --- 録音設定 (Proc00_RecordInput で使用) ---
params.recordDurationSec = 5;       % 録音時間 [s]
params.recordNumChannels = 1;       % 録音チャンネル数 (mono)
params.recordBitsPerSample = 24;    % 量子化ビット数 [bit]

% --- スペクトログラム設定 ---
params.frameSize = 2048;            % STFTフレーム長 [samples]
params.hopSize = 512;               % ホップ長 [samples]
params.windowType = 'hann';         % 窓関数
params.climDb = [-120 -40];         % 色スケール固定範囲 [dB re FS^2] (図間で色の意味を揃える)
params.colormapName = 'turbo';      % スペクトログラムのカラーマップ (MATLAB標準名)

% --- 解析設定 ---
params.plotBandHz = [20 20000];     % 図の周波数表示範囲 [Hz]

% --- 図 ---
params.figPreset = 'paper-single';  % 図スタイルプリセット (docs/rules/project.md 参照)

% --- キャッシュ ---
params.forceRecalc = false;         % true で全段を強制再計算
end
