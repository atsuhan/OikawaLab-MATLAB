function folderPath = EnsureFolder(folderPath)
% EnsureFolder - フォルダが存在しなければ作成し、パスをそのまま返す
%
% 入力:
%   folderPath - 作成したいフォルダ (char/string)
% 出力:
%   folderPath - 入力と同じパス (char)
arguments
    folderPath {mustBeTextScalar}
end

folderPath = char(folderPath);
if ~isfolder(folderPath)
    [ok, msg] = mkdir(folderPath);
    if ~ok
        error('EnsureFolder:MkdirFailed', 'フォルダを作成できません: %s (%s)', folderPath, msg);
    end
end
end
