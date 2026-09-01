# Projects — 実験ごとの解析フォルダ(メイン作業場)

## 始め方

AIに「新しい実験を始めたい」と頼む(new-experiment Skill)。手動なら:

1. `_template/` をコピーして `YYYYMMDD_テーマ名/` にリネーム
2. `README.md` と `Params.m` を埋める
3. データを `Input/` に置いて `Run` を実行

## 約束(詳細: docs/rules/project.md)

- フォルダ名は `YYYYMMDD_テーマ名`。`_` 始まりは実験ではない(終わった実験は `_archive/` へ)。
- `Proc01〜` を番号順に、`Run.m` で一気通貫。前準備は `Proc00`。
- 段の受け渡しは `Cache/Proc<NN>/*.mat`。図は `ApplyFigureStyle → ExportFigure` で `Export/` へ。
- `Input/` `Cache/` `Export/` はgit管理外。**生データは消さない・上書きしない。**
- 実験固有の関数は実験直下の `common/` へ。
