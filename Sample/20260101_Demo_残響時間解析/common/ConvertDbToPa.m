function pressurePa = ConvertDbToPa(spl)
% ConvertDbToPa - 音圧レベル SPL [dB] を音圧 [Pa] へ変換する (基準 20 µPa)
%
% 入力:
%   spl - 音圧レベル [dB re 20 µPa] (任意サイズの配列)
% 出力:
%   pressurePa - 同サイズの音圧 [Pa]
arguments
    spl double
end

referencePa = 20e-6;
pressurePa = referencePa * 10 .^ (spl / 20);
end
