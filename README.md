# OikawaLab-MATLABBase

[![CI](https://github.com/atsuhan/OikawaLab-MATLABBase/actions/workflows/ci.yml/badge.svg)](https://github.com/atsuhan/OikawaLab-MATLABBase/actions/workflows/ci.yml)

及川研究室のMATLAB実験解析テンプレート。
**cloneしてAI(Claude Code / Codex)に指示すれば、規約どおりの実験解析・図出力・進捗報告まで回る**ことを目指した、音響工学系研究室向けのベース環境です。

## クイックスタート

1. GitHubで **Use this template** → 自分のリポジトリを作成 → clone
2. 動作確認(checkcode警告0 + 全テストPASSで合格):

```bash
matlab -batch "buildtool"
```

3. リポジトリ直下で `claude` を起動し、こう頼む:
   - 「Sampleのデモ実験を動かして、図を見せて」
   - 「新しい実験を始めたい。○○の測定データを解析します」

→ 詳しい手順は [docs/setup/getting-started.md](docs/setup/getting-started.md)(最初の15分)

## フォルダ構成

| フォルダ | 役割 |
|---|---|
| `Projects/` | ★実験ごとの解析(あなたの作業場)。`_template/` をコピーして始める |
| `Reports/` | ★ゼミ発表・進捗報告の資料材料 |
| `Functions/` | 共通関数(Core=基盤 / IO / Analysis=音響・信号 / Plot=図スタイル) |
| `Sample/` | 残響時間解析のお手本実験(合成データ・正解値つき。まずこれを動かす) |
| `References/` | 参考文献(BibTeX + メモ。PDF実体はgit管理外) |
| `App/` | App Designerアプリ置き場 |
| `Tests/` `docs/` | 裏方(検証・ルール)。学生は触らなくてよい |

## 規約ダイジェスト(詳細: [docs/rules/project.md](docs/rules/project.md))

- **実験フォルダ**: `YYYYMMDD_テーマ名`。`Proc00`(前準備・目視) → `Proc01〜`(本線・番号順) + `Run.m`(一気通貫)
- **キャッシュ**: 段間は `Cache/Proc<NN>/*.mat`。重い計算は `RunCached` 経由(パラメータを変えた段だけ自動再計算)
- **図**: `plot → ApplyFigureStyle(gcf,'paper-single') → ExportFigure` の3行で論文品質。手動体裁調整は禁止
- **データ**: 生データ(`Input/`)は消さない・コミットしない。図の出所は `manifest.json` で追跡
- **検証**: `matlab -batch "buildtool"`(= checkcode警告0 + 全テスト)。未検証をPASSと報告しない

## AIエージェント環境

- 入口: `AGENTS.md`(Claude Code / Codex 共通)。曖昧な点は**質問してから進む**設計
- 専門Agent(`.claude/agents/`): **及川教授**(研究レビュー・ゼミ質問) / planner / researcher / builder / reviewer / clerk(モデル指定済み)
- Skill(`.claude/skills/`): new-experiment / run-analysis / matlab-verify / check-figures / research / seminar-prep / progress-report / status / commit-pr
- MCP: 文献検索(arXiv)同梱。MATLAB連携は [MATLAB Agentic Toolkit](docs/setup/matlab-agentic-toolkit.md) を各自導入(推奨)

## 動作要件

- MATLAB R2023a以降推奨(検証済み: R2025b)。R2025a以降で図の物理幅固定が有効
- Signal Processing Toolbox(`ApplyBandpassFilter` のみ。なくても他は動作)
- Windows / macOS(macOSは実機検証が残っています: MILESTONES B2)

## ライセンス

MIT(コードに適用。測定データ・文献は対象外)
