# OikawaLab-MATLAB — Agent Entry Point

AIエージェントはこの文書を作業の入口とする。

1. `docs/rules/lab.md` — 研究室共通ルール(MUST)
2. `docs/rules/project.md` — このリポジトリの契約・MATLAB規約
3. 作業に関係する文書だけを `docs/index.md` から選ぶ。

- 曖昧なら推測せず質問してから進む。
- 検証は `matlab -batch "buildtool"`。標準完了範囲は 検証 → commit → push → ready PRまで(mergeしない)。
- mainへ直接コミットしない。作業ブランチを切る。
- Skill: `.claude/skills/` / Agent: `.claude/agents/`(Codexは `.codex/`)。
