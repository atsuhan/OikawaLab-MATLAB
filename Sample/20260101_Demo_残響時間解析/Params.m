function params = Params()
% Params - デモ実験のパラメータ (1ファイル完結の単一正本)
%
% t60TrueSec を変えて Run すると、合成データから作り直されて
% 推定結果も変わる (キャッシュ自動無効化の体験用)。

params = struct();

% --- 合成データの設定 (この値が「正解」になる) ---
params.fs = 48000;            % サンプリング周波数 [Hz]
params.t60TrueSec = 1.2;      % 正解の残響時間 T60 [s]
params.durationSec = 2.5;     % IR長 [s] (T60の約2倍を確保)
params.noiseFloorDb = -70;    % ノイズフロア [dB]

% --- 図 ---
params.figPreset = 'paper-single';   % 図スタイルプリセット

% --- キャッシュ ---
params.forceRecalc = false;   % true で全段を強制再計算
end
