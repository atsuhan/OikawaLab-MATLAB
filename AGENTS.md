# OikawaLab-MATLABBase — Agent Entry Point

AIエージェント(Claude Code / Codex 等)は、この文書を作業の入口とする。

## 読む順序

1. `docs/rules/lab.md` — 研究室共通ルール(MUST)
2. `docs/rules/project.md` — このリポジトリの契約・MATLAB規約の正本
3. `docs/index.md` — 文書の目次
4. 現在の作業に関係する文書だけを選んで読む。**全docsの一括読み込みは禁止。**

## ルールの優先順位

1. 安全・データ保全・秘密情報の保護
2. 曖昧さの解消 — 実験条件・受入条件・削除操作が曖昧なら、推測せず質問してから進む
3. `docs/rules/project.md` の固有契約
4. `docs/rules/lab.md` のMUST
5. DEFAULTと個別指示

## 標準完了範囲

実装依頼では、検証(`matlab -batch "buildtool"`)、STATUS更新、commit、push、**ready PR作成まで**を標準完了範囲とする。
merge、ブランチ削除、force push、生データの削除・移動は行わず、人間の判断に委ねる。

## 作業の道具

- 共通ワークフローの手順書は `.claude/skills/<name>/SKILL.md` を読んで従う(Codexも同じファイルを読む)。
- 専門Agentの定義は `.claude/agents/`(Codex版は `.codex/agents/`)。
- 作業台帳は `docs/roadmap/MILESTONES.md`、人間向け現在地は `STATUS.md`(status Skillで生成)。

## commit前の確認

`git status` で現在ブランチと未コミット差分を確認し、mainへ直接コミットしない(作業ブランチを切る)。
