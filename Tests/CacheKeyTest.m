classdef CacheKeyTest < matlab.unittest.TestCase
    % CacheKeyTest - HashArrays によるキャッシュキー生成を検証する
    %
    % キャッシュキーが「入力の違いを検知できない」と、古い結果が黙って再利用される
    % 事故につながる(移植元リポジトリで実害があった)。本テストは
    %   - SHA-256 プリミティブが標準既知ベクタと一致すること
    %   - 同一入力 -> 同一キー / 入力の違い(転置・順序・微小差) -> 異なるキー
    % を固定する。

    methods (Test)

        function sha256PrimitiveMatchesStandardKnownVector(testCase)
            % HashArrays が内部で使う SHA-256 プリミティブ (java.security.MessageDigest)
            % が標準既知ベクタ SHA-256('abc') と一致することを確認する。
            digestEngine = java.security.MessageDigest.getInstance('SHA-256');
            digestEngine.update(uint8('abc'));
            rawBytes = typecast(digestEngine.digest(), 'uint8');
            hex = lower(reshape(dec2hex(rawBytes, 2).', 1, []));
            testCase.verifyEqual(hex, ...
                'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
        end

        function identicalInputsGiveIdenticalKey(testCase)
            % 安定性: 同一内容の配列を独立に再構築しても同じ64文字キーになること。
            dataA = struct('sig', sin(2 * pi * (0:99).' / 100), 'fs', 48000);
            dataB = struct('sig', sin(2 * pi * (0:99).' / 100), 'fs', 48000);

            keyA = HashArrays(dataA.sig, dataA.fs, 'method-a');
            keyB = HashArrays(dataB.sig, dataB.fs, 'method-a');

            testCase.verifyEqual(keyA, keyB, ...
                '同一入力から独立に構築したキーが一致しません (安定性が壊れています)。');
            testCase.verifyEqual(numel(keyA), 64, 'SHA-256 hexは64文字であるべき。');
        end

        function transposeProducesDifferentKey(testCase)
            % 転置しただけの配列 ([N x 2] と [2 x N]) を区別できること。
            % size 情報をハッシュへ含めないと転置は同一バイト列になり衝突する。
            matA = reshape(1:10, 5, 2);
            keyA = HashArrays(matA);
            keyB = HashArrays(matA.');
            testCase.verifyNotEqual(keyA, keyB, ...
                '転置違いをキャッシュキーで検知できていません。');
        end

        function argumentOrderProducesDifferentKey(testCase)
            % 引数の順序を入れ替えると異なるキーになること。
            keyA = HashArrays(1, 2);
            keyB = HashArrays(2, 1);
            testCase.verifyNotEqual(keyA, keyB, ...
                '引数順の違いをキャッシュキーで検知できていません。');
        end

        function tinyNumericDifferenceIsDistinguished(testCase)
            % 丸め表示では消える微小差 (1e-3) も倍精度バイト列レベルで区別できること。
            keyLow  = HashArrays(343.001);
            keyHigh = HashArrays(343.002);
            testCase.verifyNotEqual(keyLow, keyHigh, ...
                '微小な数値差がキーで区別できていません。');
        end

        function complexAndLogicalInputsAreSupported(testCase)
            % 複素数・logical も一意に符号化できること。
            keyComplex = HashArrays([1 + 2i, 3 - 4i]);
            keyConj    = HashArrays([1 - 2i, 3 + 4i]);
            testCase.verifyNotEqual(keyComplex, keyConj, ...
                '複素共役の違いを区別できていません。');

            keyTrue  = HashArrays(true);
            keyFalse = HashArrays(false);
            testCase.verifyNotEqual(keyTrue, keyFalse);
        end

        function unsupportedTypeThrowsIdentifiedError(testCase)
            % struct は非対応 (呼び出し側でフィールド展開する契約)。
            testCase.verifyError(@() HashArrays(struct('a', 1)), ...
                'HashArrays:UnsupportedType');
        end

        function noInputThrowsIdentifiedError(testCase)
            % 引数ゼロはエラー (キーなしキャッシュを作らせない)。
            testCase.verifyError(@() HashArrays(), 'HashArrays:NoInput');
        end

    end
end
