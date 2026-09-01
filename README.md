# OikawaLab-MATLAB

[![CI](https://github.com/atsuhan/OikawaLab-MATLAB/actions/workflows/ci.yml/badge.svg)](https://github.com/atsuhan/OikawaLab-MATLAB/actions/workflows/ci.yml)

及川研究室のMATLAB実験解析テンプレート。cloneしてAI(Claude Code / Codex)に指示すれば、規約どおりの実験解析と図出力が回るベース環境。

## クイックスタート

1. GitHubで **Use this template** → 自分のリポジトリを作成 → clone
2. 動作確認:

```bash
matlab -batch "buildtool"
```

3. `claude` を起動して「Sampleのデモ実験を動かして」「新しい実験を始めたい」と頼む。

詳細: [docs/setup/getting-started.md](docs/setup/getting-started.md)

## フォルダ構成

| フォルダ | 役割 |
|---|---|
| `Projects/` | ★実験ごとの解析(作業場)。`_template/` をコピーして始める |
| `Reports/` | ★発表・報告資料 |
| `Functions/` | 汎用共通関数(Core / IO / Plot) |
| `Sample/` | お手本実験(残響時間解析。音響関数の例もここ) |
| `References/` | 文献(BibTeX + メモ) |
| `Tests/` `docs/` | 裏方。学生は触らなくてよい |

## 規約の要点(正本: [docs/rules/project.md](docs/rules/project.md))

- 実験フォルダは `YYYYMMDD_テーマ名`。`Proc01〜` を `Run.m` で順に実行。
- 図は `plot → ApplyFigureStyle → ExportFigure` の3行。
- 生データ(`Input/`)は消さない・コミットしない。
- 検証は `matlab -batch "buildtool"`。

## 動作要件

- MATLAB R2023a以降(検証済み: R2025b)。Windows / macOS。
- Signal Processing Toolbox(Sampleの一部関数のみ)。

## ライセンス

MIT(コードのみ。データ・文献は対象外)
