function soundSpeed = GetSoundSpeed(temperatureC)
% GetSoundSpeed - 気温 [degC] から空気中の音速 [m/s] を返す
%
% c = 331.3 * sqrt(1 + T / 273.15)。乾燥空気の近似式。
%
% 入力:
%   temperatureC - 気温 [degC] (任意サイズの配列。既定: 20)
% 出力:
%   soundSpeed - 同サイズの音速 [m/s] (20 degC で約 343.2 m/s)
arguments
    temperatureC double = 20
end

soundSpeed = 331.3 * sqrt(1 + temperatureC / 273.15);
end
