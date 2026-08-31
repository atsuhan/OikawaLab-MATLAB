function repoRoot = FindRepoRoot()
% FindRepoRoot - リポジトリルートの絶対パスを返す
%
% 本ファイルが <repoRoot>/Functions/Core/ に置かれる前提でルートを導出し、
% 目印フォルダ (Functions/ と Projects/) の存在を検証する。
% 実験スクリプトから Cache/Export 以外のリポジトリ内パスを組み立てるときに使う。
%
% 出力:
%   repoRoot - char リポジトリルートの絶対パス

thisDir      = fileparts(mfilename('fullpath'));   % Functions/Core
functionsDir = fileparts(thisDir);                 % Functions
repoRoot     = fileparts(functionsDir);            % リポジトリルート

if ~isfolder(fullfile(repoRoot, 'Functions')) || ~isfolder(fullfile(repoRoot, 'Projects'))
    error('FindRepoRoot:NotARepo', ...
        'リポジトリルートを特定できません (Functions/Projects が見つかりません): %s', repoRoot);
end
end
