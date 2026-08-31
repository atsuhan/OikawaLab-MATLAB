# Reports — 資料書き出し場所

ゼミ発表・進捗報告・卒論などの資料の材料をまとめる場所。`seminar-prep` Skill の出力先。

## 構成

```
Reports/YYYYMMDD_種別_テーマ/     例: 20260920_ゼミ発表_残響時間測定
├── memo.md          発表メモ・構成(git追跡。雛形: _template/memo.md)
├── sources.json     図の出所記録(CollectExportsが自動生成。git追跡)
└── assets/          収集した図の実体(git管理外。CollectExportsで再収集できる)
```

- 種別の語彙: `ゼミ発表` / `進捗報告` / `中間発表` / `卒論` / `学会`
- 図は実験の `Export/` から `CollectExports` で収集する(手コピーしない)。
  `sources.json` に「どの実験の・どのパラメータ(paramsHash)の図か」が残り、後から再現できる。
- 発表後の指摘・質疑は `memo.md` に追記して残す(消さない)。

## 使い方

AIに「○○の実験でゼミ資料を作って」と頼むと、材料収集→memo.md下書き→及川教授Agentのレビューまで行われる。
