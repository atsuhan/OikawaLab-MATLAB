# OikawaLab Agent Rules

Lab-Harness-Version: 1.1.0

すべてのAIエージェント(Claude Code / Codex 等)の共通ルール。リポジトリ固有の契約は `docs/rules/project.md`。

## MUST

- 実験条件・データの意味・受入条件・削除操作が曖昧なら、推測せず質問してから進む。推測で埋めた箇所は「推測」と明記。
- 生データ(`Input/` 配下)を削除・上書きしない。派生データは別名で保存。
- 図は `ApplyFigureStyle` + `ExportFigure` を通す。
- 未検証をPASS・完了と報告しない(UNVERIFIEDと明記)。受入条件を後から緩めない。
- 秘密情報・個人情報をcommit・外部送信しない。
- 実験記録・decision・Milestoneを削除や要約で上書きしない。訂正は追記。
- 復旧困難な削除・force push・公開操作は承認なしに行わない。

## 質問の仕方

- まとめて1回、各質問に選択肢と推奨案を付ける。文書で答えが出るものは質問しない。
- subagentは質問リストを親へ返し、親が AskUserQuestion で確認する。

## Git

- 作業開始時に `git status` 確認。mainへ直接コミットせず、`exp/` または `feat/` ブランチを切る。
- 標準完了範囲: 検証 → STATUS更新 → commit → push → ready PR作成まで。
- merge・ブランチ削除・force push・生データ操作は人間に委ねる。

## Research

- 公式文書・一次資料を優先し、公開日・URLを記録。論文は本文を確認してから引用。
- 文献は `References/`(references.bib + Notes/)へ整理。

## 文書と状態

- 人間向け現在地: `STATUS.md`(status Skillで生成)。作業台帳: `docs/roadmap/MILESTONES.md`。
- 技術判断: `docs/decisions/decisions.md` に追記。一時ログをdocsへ蓄積しない。
- MUSTは必須。DEFAULTは理由をdecisionsに残せば変更可。CONSIDERは任意。
