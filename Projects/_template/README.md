# (実験名をここに)

> このREADMEは実験の一次資料。実験を始めたら空欄を埋め、変更・訂正は消さずに追記する。

## 目的

- (何を明らかにする実験か。1〜3行)

## 測定条件

| 項目 | 値 |
|---|---|
| 測定日 | YYYY-MM-DD |
| 場所 | (例: 無響室 / 講義室301) |
| マイク | (型番・本数) |
| サンプリング周波数 | 48000 Hz |
| 校正値 | (例: 1.0 Pa/FS。未校正なら「未校正」) |
| その他 | (温湿度、機材設定、注意点) |

## データの中身(Input契約)

- `Input/*.wav` — (何の録音か。ch対応: ch1=○○, ch2=○○。単位: フルスケール±1)
- (matファイルを置く場合は変数名・次元 `[N x Ch]`・単位も書く)

## 実行方法

```matlab
% MATLABでこのフォルダをカレントにして:
Proc00_CheckInput   % 初回のみ: データの目視確認
Run                 % Proc01〜03 を一気通貫実行
```

パラメータは `Params.m` が単一の正本。変えたら `Run` を再実行(変わった段だけ再計算される)。

## 出力(Output契約)

- `Cache/Proc01/prepared.mat` — 読み込み済み波形 (`data.audioList {1xK}` 各 `[N x Ch]`, `data.fsList [1 x K]` Hz)
- `Cache/Proc02/spectrum.mat` — 片側振幅スペクトル (`data.spectra {1xK}` 各 struct: freqHz/amplitude)
- `Export/*.png` + `Export/manifest.json` — 図とパラメータ対応の記録

## 結果メモ(追記式)

- YYYY-MM-DD: (わかったこと・気づき。訂正するときは古い記述を消さず「⚠️訂正:」で追記)
