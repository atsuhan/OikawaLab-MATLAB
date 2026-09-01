# Decisions — 長期的な技術判断(追記専用)

方針を覆すときは旧記録を消さず、新しいdecisionから差し替えを明記する。

## 2026-08-31 初期構築の主要判断

- **D1 パス管理**: MATLAB Project(.prj)ではなく `SetupProjectPaths` 方式を採用。
  理由: 実験ごとに同名ファイル(Params.m等)が並ぶ研究リポジトリでは、path上の解決先の一意性を機械強制できる方式が安全(移植元のINSPIREI-OTOMIRU-MATLABで実運用実績)。`.prj` はGit運用との相性と学生の理解コストで見送り。再検討条件: MATLAB Projects側の複数実験サポートが改善した場合。
- **D2 検証ゲート**: `buildtool`(check=checkcode警告0 + test)を主入口、`RunAllChecks` をフォールバックとする。CIとローカルで同一定義。
- **D3 図出力**: `exportgraphics` ベースの `ExportFigure` に統一。export_figは外部依存(Ghostscript)があるため不採用。
- **D4 STATUS生成**: スクリプトでなくstatus Skill+clerkによる生成。理由: OS非依存・依存ゼロ。決定性が必要になったらMATLAB実装を再検討。
- **D5 Gitワークフロー**: 標準完了範囲はPR作成まで。自動mergeは学生複数名の運用では採用しない(INSPIREIハーネスからの意図的変更)。
- **D6 development-loop(自走ループ)Skill**: 初版では同梱しない(CONSIDER)。学生初心者×自律ループは事故要因が大きく、質問優先設計と相性が悪い。運用が安定したら再検討。
- **D7 MCP**: コミットするのはパス非依存のarxiv-mcp-serverのみ。MATLAB Agentic Toolkitは1ユーザー1インストール原則のため各自導入(docs/setup/)。

## 2026-09-01: リポジトリを OikawaLab-MATLAB に改名し、構造を簡素化

- 改名: OikawaLab-MATLABBase → OikawaLab-MATLAB(GitHub・ローカルフォルダとも)。
- Functions/ は汎用基盤(Core / IO / Plot)のみに縮小。音響解析関数(旧 Functions/Analysis + GenerateSyntheticImpulseResponse)は Sample/20260101_Demo_残響時間解析/common/ へ移動。「2実験以上で使ってから昇格」の原則に合わせた。
- テスト(AcousticsTest / SignalProcessingTest)は PathFixture でSample commonを参照し、カバレッジは維持。
- Cache/RunCached は必須契約から任意の道具に格下げ。Proc番号規約は「Proc00=前準備、Proc01〜本線、Run.mで完走」だけに簡略化。
- ドキュメント(README / AGENTS / rules / CLAUDE.md)を全体的に短縮。
