# Demo: 残響時間解析(合成データ)

リポジトリの使い方を一通り体験するためのお手本実験。
**残響時間が既知(T60 = 1.2 s)の合成インパルス応答**を生成して解析するので、
「解析が正しく動いている」ことを自分の目で確認できる。実データ・Toolboxは不要。

## 動かし方

```matlab
% MATLABでこのフォルダをカレントにして:
Proc00_MakeData     % 初回のみ: 合成データを生成して波形を目視確認
Run                 % Proc01〜03 を一気通貫実行 → Export/ に図が出る
```

もう一度 `Run` すると、今度はキャッシュが効いて一瞬で終わる。
`Params.m` の `t60TrueSec` を変えて `Run` すると、変更に関係する段だけが再計算される。

## Claude Code への指示例

このリポジトリはAIエージェントでの解析を前提にしている。例えばこう頼める:

- 「SampleのデモでT60を2秒に変えて図を出して」
- 「デモの減衰曲線の図をスライド用サイズで出し直して」
- 「このデモを参考に、新しい実験フォルダを作って(→ new-experiment Skill が動く)」

## パイプライン

| 段 | 役割 | 出力 |
|---|---|---|
| Proc00_MakeData | 合成IR生成 + 波形の目視確認(初回のみ) | `Input/demo_ir.wav` |
| Proc01_Prepare | IR読み込み | `Cache/Proc01/prepared.mat` |
| Proc02_EstimateRT | Schroeder減衰曲線 + T20/T30推定 | `Cache/Proc02/reverb.mat` |
| Proc03_Visualize | 減衰曲線・スペクトログラムの図 | `Export/*.png` + `manifest.json` |

## 正解値との照合

Proc02 が推定T60と設定値(`params.t60TrueSec`)の誤差を表示する。誤差が数%以内なら正常。
この「正解と突き合わせる」流れは `Tests/SampleSmokeTest.m` でも自動検証されている。

## 結果メモ(追記式)

- 2026-01-01: 初版。T60=1.2s設定でT30推定誤差 3%以内を確認。
