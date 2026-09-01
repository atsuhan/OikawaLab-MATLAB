# Project Rules — OikawaLab-MATLAB

このリポジトリの契約とMATLAB規約の正本。名称がずれたらここに合わせる。

## 名称契約

| 項目 | 値 |
|---|---|
| 検証 | `matlab -batch "buildtool"`(check + test) |
| パス設定 | `Functions/Core/SetupProjectPaths.m`(`addpath(genpath())` 禁止) |
| 図 | `ApplyFigureStyle` + `ExportFigure`(直接の `saveas`/`print` 禁止) |
| 実験フォルダ | `Projects/YYYYMMDD_テーマ名/`(`_template/` をコピー) |
| 資料 | `Reports/YYYYMMDD_種別_テーマ/` |
| 文献 | `References/`(references.bib + Notes/) |

## フォルダ

- `Functions/` — 実験横断の汎用関数のみ(Core / IO / Plot / Signal)。変更時はTests/の更新必須。
- `Projects/` — 実験ごとの解析。学生の作業場。実験固有の関数は各実験の `common/` へ。
- `Sample/` — お手本実験(音響解析の関数例もここの `common/` にある)。
- `Tests/` `docs/` — 裏方。

## 実験スクリプト

- `Proc01_`〜 を番号順に書き、`Run.m` が順に呼んで `matlab -batch` で完走すること。
- 前準備・目視確認は `Proc00_*`(Run.mに含めない)。それ以外の番号運用は自由。
- 段の結果は `Cache/Proc<NN>/*.mat` に保存して次段がloadする。
- 重い計算は `RunCached` を使うと再計算をスキップできる(任意)。
- matファイルの中身(変数・次元・単位)は実験READMEに書く。

## 図

- `plot → ApplyFigureStyle(gcf, プリセット) → ExportFigure`。手動の体裁調整はしない。
- プリセット: `paper-single` / `paper-double` / `slide` / `a4report`。出力は各実験の `Export/`。

## コーディング規約

- 1ファイル1公開関数。ファイル名=関数名、PascalCase、動詞始まり。H1コメント必須。
- 入出力は次元と単位をヘッダに書く(例: `audioData [N x Ch] 音圧 [Pa]`)。
- 変数はcamelCase。配列は事前確保。checkcode警告ゼロ。
- 関数名はリポジトリ全体で一意(テストで強制)。`+package` / `@class` は使わない(classdefはTests/のみ)。
- 2つ以上の実験で使って初めて `Functions/` へ昇格。昇格時に数値一致テストを書く。

## Toolbox

- 許可: Signal Processing Toolbox。追加時はCIの `products` とREADMEを同時更新。
