@docs/rules/lab.md
@docs/rules/project.md

# Claude Code

- 入口は `AGENTS.md`。曖昧なら AskUserQuestion で確認してから進む。
- 図は `ApplyFigureStyle` / `ExportFigure` を通す。
- 共通ワークフローは `.claude/skills/`、専門Agentは `.claude/agents/`。
- subagentからの質問リストは、親が AskUserQuestion でユーザーに確認する。
