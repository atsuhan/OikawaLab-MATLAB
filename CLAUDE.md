@docs/rules/lab.md
@docs/rules/project.md

# Claude Code

- 作業の入口と優先順位は `AGENTS.md` に従う。
- 実験条件・データの意味・受入条件が曖昧なときは、推測せず AskUserQuestion で確認してから進む。
- 必要な文書だけ `docs/index.md` から選ぶ。
- 共通ワークフローは `.claude/skills/`、専門Agentは `.claude/agents/` を使用する。
- 図を出力する処理は必ず `ApplyFigureStyle` / `ExportFigure` を通す。
- 書き込みAgentへ委譲するときは、対象範囲、受入条件、禁止事項、未確定の質問リストを明示する。
- subagentから返された質問リストは、親会話が AskUserQuestion でユーザーに確認してから作業を続ける。
