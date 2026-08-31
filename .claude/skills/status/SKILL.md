---
name: status
description: MILESTONESとGitの証拠からSTATUS.md(人間向け現在地)を生成・更新する。「STATUSを更新して」「現在地をまとめて」で使用する。進捗を尋ねられたときにも使う。
---

# status

## 手順

1. `docs/roadmap/MILESTONES.md` と `git log --oneline -15`、`git status` を読む。
2. clerk Agentへ委譲し、ルートの `STATUS.md` を以下の固定テンプレートで全置換させる:

```markdown
<!-- generated-by: status skill。手編集しない(次回生成で消える)。正本は docs/roadmap/MILESTONES.md -->
# STATUS

最終更新: YYYY-MM-DD

## 現在の重点
- (進行中の実験・作業を1〜3行。必ずMilestone IDを付ける)

## 作業中
- **<ID>** <タイトル> — (直近の進捗メモの要約1行)

## 次に着手できる
- **<ID>** <タイトル>(依存が解消済みの未着手項目)

## 確認待ち・ブロック中
- (人間の判断待ち・データ待ちの項目。なければ「なし」)

## 最近完了
- **<ID>** <タイトル>(直近5件まで)
```

3. 各行は MILESTONES.md または git log に証拠がある内容だけにする。進捗率・完了予測は書かない。
4. 生成後、内容がMILESTONESと矛盾していないか親が確認して報告する。
