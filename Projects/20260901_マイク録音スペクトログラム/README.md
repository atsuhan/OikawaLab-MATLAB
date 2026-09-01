# マイク録音スペクトログラム

> このREADMEは実験の一次資料。実験を始めたら空欄を埋め、変更・訂正は消さずに追記する。

## 目的

- PCの既定マイクから5秒間録音し、スペクトログラムを出力する。
- 録音→解析→図出力の一連のパイプラインを本リポジトリの規約に沿って構築するデモ。

## 測定条件

| 項目 | 値 |
|---|---|
| 測定日 | 2026-09-01 |
| 場所 | (録音した場所を記入) |
| マイク | PC既定入力デバイス (型番未記録) |
| サンプリング周波数 | 48000 Hz |
| 校正値 | 未校正 (フルスケール±1のまま扱う) |
| その他 | 録音時間 5 s / mono / 24 bit |

## データの中身(Input契約)

- `Input/recording_<yyyyMMdd-HHmmss>.wav` — Proc00でのマイク録音。mono、単位: フルスケール±1(未校正)。
- 手持ちのwavを解析したい場合もここに置けばよい(fsが48000 Hzでない場合は警告のうえそのまま解析)。

## 実行方法

```matlab
% MATLABでこのフォルダをカレントにして:
Proc00_RecordInput  % マイクから5秒録音 -> Input/へ保存 + 波形の目視確認 (要マイク)
Run                 % Proc01〜03 を一気通貫実行 (ヘッドレス可)
```

ヘッドレス: `matlab -batch "cd('Projects/20260901_マイク録音スペクトログラム'); Run"`
(録音を含むProc00は対話環境でのみ実行する)

パラメータは `Params.m` が単一の正本。変えたら `Run` を再実行(変わった段だけ再計算される)。

## 出力(Output契約)

- `Cache/Proc01/prepared.mat` — 読み込み済み波形 (`data.audioList {1xK}` 各 `[N x Ch]` フルスケール±1, `data.fsList [1 x K]` Hz, `data.nameList {1xK}`)
- `Cache/Proc02/spectrogram.mat` — スペクトログラム (`data.spectrograms {1xK}` 各 struct: `timeSec [T x 1]` s / `freqHz [F x 1]` Hz / `powerDb [F x T]` dB / `fs` Hz)
- `Export/spectrogram_*.png` + `Export/manifest.json` — 図とパラメータ対応の記録

## 結果メモ(追記式)

- 2026-09-01: プロジェクト作成。録音実行はまだ(要マイク環境)。
