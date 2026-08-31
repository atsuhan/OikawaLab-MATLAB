function spl = ConvertPaToDb(pressurePa)
% ConvertPaToDb - 音圧 [Pa] を音圧レベル SPL [dB] へ変換する (基準 20 µPa)
%
% 入力:
%   pressurePa - 音圧の実効値または振幅 [Pa] (任意サイズの配列。絶対値を取る)
% 出力:
%   spl - 同サイズの音圧レベル [dB re 20 µPa]。ゼロ入力は eps でガード
arguments
    pressurePa double
end

referencePa = 20e-6;
spl = 20 * log10(max(abs(pressurePa), eps) / referencePa);
end
