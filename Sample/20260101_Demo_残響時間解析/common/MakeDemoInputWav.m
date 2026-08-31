function wavPath = MakeDemoInputWav(projectDir, params)
% MakeDemoInputWav - デモ用の合成インパルス応答を Input/demo_ir.wav へ生成する
%
% Proc00 (目視確認) と Proc01 (データがない場合の自動生成) の両方から呼ばれる。
% シード固定なので何度呼んでも同じデータになる。
%
% 入力:
%   projectDir - この実験フォルダの絶対パス
%   params     - Params() の戻り値 (fs / t60TrueSec / durationSec / noiseFloorDb)
% 出力:
%   wavPath - 生成した wav の絶対パス

[ir, ~, ~] = GenerateSyntheticImpulseResponse(params.fs, params.t60TrueSec, ...
    params.durationSec, 'NoiseFloorDb', params.noiseFloorDb);

inputDir = EnsureFolder(fullfile(projectDir, 'Input'));
wavPath = fullfile(inputDir, 'demo_ir.wav');
SaveAudioFile(wavPath, ir, params.fs);
end
