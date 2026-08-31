# Project Rules — OikawaLab-MATLABBase

このファイルはリポジトリ固有の契約とMATLAB規約の**一元正本**です。
Skill・CI・テストと名称がずれた場合は、このファイルに合わせて直します。

## 名称契約(正本)

| 項目 | 確定値 |
|---|---|
| 検証コマンド | `matlab -batch "buildtool"`(= check + test)。個別は `buildtool check` / `buildtool test` |
| フォールバック検証 | `matlab -batch "addpath('Tests/tools'); RunAllChecks"` |
| パス設定関数 | `Functions/Core/SetupProjectPaths.m`(`addpath(genpath())` は禁止) |
| 図スタイル関数 | `Functions/Plot/ApplyFigureStyle.m` / `Functions/Plot/ExportFigure.m` |
| 実験テンプレート | `Projects/_template/`(コピーして使う) |
| 実験フォルダ命名 | `Projects/YYYYMMDD_テーマ名/`(複数人共有時は `YYYYMMDD_名字_テーマ名`) |
| 資料出力先 | `Reports/YYYYMMDD_種別_テーマ/`(種別: ゼミ発表 / 進捗報告 / 中間発表 / 卒論) |
| 文献置き場 | `References/`(references.bib + `Notes/<citekey>.md`。PDF実体は `_local/`=git管理外) |
| 関数索引 | `docs/functions-reference.md`(`buildtool index` で自動生成。手編集しない) |

## フォルダの役割

- `Functions/` — 実験横断の共通関数。**変更時はTests/のテスト追加・更新が必須。**
- `Projects/` — 実験ごとの解析。学生のメイン作業場。`_` 始まり(`_template`, `_archive`)は実験ではない。
- `Sample/` — 合成データのお手本実験。壊れたらテンプレートからやり直せる教材。
- `References/` / `Reports/` — 文献と発表資料。
- `Tests/` / `docs/` — 裏方。学生は直接触らなくてよい。

## Proc規約(実験の段階スクリプト)

- `Proc00_*`: 前準備・データ目視確認。初回に単独実行する。`Run.m` には含めない。
- `Proc01_`〜: 本線。番号順=依存順。各Procは単独実行可能に保つ。
- `Proc10` 番台: 試行錯誤・検証の枝(本線を汚さない)。
- `Proc99_*`: ユーティリティ(Cache掃除等)。
- `Run.m` は Proc01〜 を順に呼び、ヘッドレス(`matlab -batch`)で完走できること。
- Procは読めるスクリプトとして書く(セル区切り `%%`、コメント多め)。処理が肥大したら `common/` へ関数化する。

## Cache契約(段間の受け渡し)

- 段の出力は `Cache/Proc<NN>/<名前>.mat` に保存し、次の段がloadする。これが唯一の受け渡し経路。
- 重い計算は `RunCached` を通す。入力ハッシュが一致すれば再計算をスキップする(`forceRecalc` で強制再計算)。
- 手法比較をするときはCacheディレクトリを分ける(例: `Cache/Proc02_MethodA/`)。上書き比較はしない。
- matファイルの中身(変数名・次元・単位)は実験フォルダのREADME「データの中身」節に表で書く。

## 図の契約

- 作図は `plot → ApplyFigureStyle(gcf, プリセット名) → ExportFigure` の3ステップ。
- プリセット: `paper-single`(論文1段組) / `paper-double`(論文2段組) / `slide`(ゼミスライド) / `a4report`(レポート)。
- `set(gca,'FontSize',...)` などの手動体裁調整はしない。調整は `ApplyFigureStyle` のオプションで行う。
- 出力は各実験の `Export/` へ。`ExportFigure` がタイムスタンプ付きファイル名と `manifest.json`(どのパラメータで作った図か)を自動で残す。

## MATLABコーディング規約

- 1ファイル1公開関数(ローカル関数は可)。ファイル名=関数名、PascalCase、動詞始まり(Compute/Load/Apply/Estimate/Generate/Get/Export)。
- 関数の1行目直後にH1コメント(1行要約、日本語可)必須。索引生成(`buildtool index`)がH1欠落でエラーになる。
- 入出力はヘッダコメントに次元と単位を書く: `audioData [N x Ch] 音圧 [Pa]` の形式。
- 入力検証は `arguments` ブロックを推奨。
- `+package` / `@class` フォルダは使わない。`classdef` は `Tests/` のみ。
- 関数のbasenameはリポジトリ全体で一意(テストで機械強制)。
- 変数はcamelCase。ループ内で配列を成長させない(事前確保する。checkcode警告ゼロが必須)。
- 「等価性を確認せず共通化しない」— 2つ以上の実験で同じ処理が確認できてから `Functions/` へ昇格し、昇格時に数値一致テストを書く。

## Toolbox依存

- 許可: Signal Processing Toolbox(`Functions/Analysis/` の一部)。
- 他のToolboxに依存する関数を追加する場合は、`.github/workflows/ci.yml` の `products` とREADMEの動作要件を同時に更新する。

## Specialists

- 音響理論・実験計画・結果解釈・発表資料のレビューは `professor`(及川教授)を使う。
- 文献調査は `researcher`、実装は `builder`、コード品質確認は `reviewer`。

## Codexモデル名について

- `.codex/agents/*.toml` のモデル名は作成時点の現行名。陳腐化した場合は各自の環境の現行モデル名へ読み替えてよい(DEFAULT)。
