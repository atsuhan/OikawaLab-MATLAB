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

## 2026-09-01: ComputeSpectrogram / GenerateWindow を Functions/Signal/ へ昇格

- マイク録音スペクトログラム実験(E1-1)がSampleの同2関数をコピー使用し「2実験以上で使用」の昇格条件を満たしたため、`Functions/Signal/` を新設して移動。数値検証は既存の `Tests/SignalProcessingTest.m`(正弦波での振幅・ピーク周波数一致)がそのままカバーする。
- カテゴリ追加に伴い project.md のFunctions欄を (Core / IO / Plot / Signal) に更新。
- 併せてチーム監査(reviewer/professor)の指摘を反映:
  - `buildtool check` の対象に `Projects/**` を追加(新規実験コードが検査対象外だった)。
  - `powerDb` の定義をヘッダに明記: dB re 入力単位^2、片側スペクトルの係数2なし、可視化用の相対値。図のカラーバーも「dB re FS^2 (未校正)」表記に統一。本実験は動作デモ目的のため絶対校正は行わない(定量利用時に再検討)。
  - `SaveAudioFile` に BitsPerSample オプションを追加(既定16bit、録音実験は24bit保存)。
  - `RecordMicrophone` はデバイス実fsを返し、fs不一致・無音・クリップを警告する。
