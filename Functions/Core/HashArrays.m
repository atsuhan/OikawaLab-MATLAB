function hex = HashArrays(varargin)
% HashArrays - 複数配列を size 情報込みで正準化し SHA-256 (小文字16進64文字) を返す
%
% キャッシュキー生成用の汎用ヘルパー。各引数を
%   [型タグ 1byte][次元数 1byte][size(...) を double化したバイト列][データ本体]
% の順でバイト列化し連結してから java.security.MessageDigest('SHA-256') で
% ハッシュ化する。size(...) を明示的に含めるため、転置しただけの配列
% (例: [P x 3] と [3 x P]) は要素の並びが同じでも異なるハッシュになる。
% 引数の個数・順序を変えても異なるハッシュになる。
%
% 対応する型: 数値配列 (double/single/整数/logical、複素数含む)・char・string
%   (スカラー/配列)。struct はサポートしない (呼び出し側でフィールドを展開し、
%   個々の値を引数として渡すこと)。
%
% 用途例 (RunCached と組み合わせる):
%   key = HashArrays(irData, fs, bandFreqs, params.smoothingSpanSec);
%
% 入力: 可変長引数 (各引数は上記いずれかの型)
% 出力: hex - 1x64 char の小文字16進 SHA-256 ダイジェスト
%
% 検証: 本関数が使う SHA-256 プリミティブ (java.security.MessageDigest) は
% Tests/CacheKeyTest.m で 'abc' の標準既知ベクタと突合済み。HashArrays 自体は
% 型タグ・size プレフィックスを付与するため、生バイト列の SHA-256 とは一致
% しない (設計通り。衝突検知のための意図的なフレーミング)。
%
% 既知の制約: java.security.MessageDigest を使うため、JVM なし
% (`matlab -nojvm`) では動作しない。`matlab -batch` は JVM ありなので問題ない。

if nargin == 0
    error('HashArrays:NoInput', '少なくとも1つの引数が必要です。');
end

digestEngine = java.security.MessageDigest.getInstance('SHA-256');
for k = 1:numel(varargin)
    digestEngine.update(EncodeArgument(varargin{k}));
end

rawBytes = typecast(digestEngine.digest(), 'uint8');
hex = lower(reshape(dec2hex(rawBytes, 2).', 1, []));
end

% =========================================================================
function bytes = EncodeArgument(value)
% EncodeArgument - 1引数を [型タグ][次元数][size][データ] のuint8バイト列へ変換

if isstring(value)
    % string配列は要素間を区切り文字で連結してから char として扱う
    % (要素境界の曖昧さを避けるため長さも size プレフィックスに含まれる)
    value = char(strjoin(value(:), sprintf('\x1f')));
end

if ischar(value)
    typeTag = uint8('C');
    sizeVec = double(size(value));
    payload = reshape(uint8(unicode2native(value, 'UTF-8')), 1, []);
elseif isnumeric(value) || islogical(value)
    typeTag = uint8('N');
    sizeVec = double(size(value));
    valueDouble = double(value);
    if isreal(valueDouble)
        payload = reshape(typecast(valueDouble(:), 'uint8'), 1, []);
    else
        % 実部・虚部を交互に並べてから倍精度バイト列化 (複素配列も一意に符号化)
        interleaved = zeros(2 * numel(valueDouble), 1);
        interleaved(1:2:end) = real(valueDouble(:));
        interleaved(2:2:end) = imag(valueDouble(:));
        payload = reshape(typecast(interleaved, 'uint8'), 1, []);
    end
else
    error('HashArrays:UnsupportedType', ...
        'サポート外の型です (%s)。数値配列/logical/char/string のみ対応。', class(value));
end

% typecast はスカラー(1要素)入力に対して行/列の向きが不定になり得るため、
% '.' による転置に頼らず reshape(...,1,[]) で常に行に強制する。
sizeBytes = reshape(typecast(sizeVec, 'uint8'), 1, []);
bytes = uint8([typeTag, uint8(numel(sizeVec)), sizeBytes, payload]);
end
