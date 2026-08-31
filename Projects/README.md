# Projects — 実験ごとの解析フォルダ(あなたのメイン作業場)

## 新しい実験の始め方

一番簡単なのはAIに頼むこと: 「新しい実験を始めたい。○○の測定データを解析します」
(new-experiment Skill が質問しながらフォルダ一式を作る)

手動でやる場合:

1. `_template/` をコピーして `YYYYMMDD_テーマ名/` にリネームする
2. `README.md` と `Params.m` の空欄を埋める
3. データを `Input/` に置く → `Proc00_CheckInput` で目視確認 → `Run`

## 命名規則

- `YYYYMMDD_テーマ名`(日付は実験日または解析着手日。例: `20260915_残響時間測定_講義室`)
- 複数人で1リポジトリを共有する場合は `YYYYMMDD_名字_テーマ名`
- `_` 始まり(`_template`, `_archive`)は実験ではない印。終わった実験は `_archive/` へ移す

## フォルダの約束(詳細: docs/rules/project.md)

- `Proc00`=前準備(目視)、`Proc01〜`=本線(番号順)、`Proc10番台`=試行錯誤の枝、`Proc99`=ユーティリティ
- 段の受け渡しは `Cache/Proc<NN>/*.mat` のみ。重い計算は `RunCached` を通す(2回目から一瞬)
- 図は `ApplyFigureStyle` → `ExportFigure` で `Export/` へ(3行で論文品質になる)
- `Input/` `Cache/` `Export/` はgit管理外。**生データは消さない・上書きしない**
- 条件違いの試行が複数あるときは、実験フォルダの中にサブフォルダを切る(それぞれに Params.m + Proc*.m、共通処理は実験直下の `common/` へ)
