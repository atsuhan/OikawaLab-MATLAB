---
name: commit-pr
description: 作業を意図単位でcommitし、push、ready PR作成までを行う(mergeはしない)。「commitして」「PRを作って」「作業をまとめて」の依頼で使用する。
---

# commit-pr

## 手順

1. `git status` と `git diff` で変更内容を確認する。意図しない差分(一次データ、大容量ファイル、他人の作業)が混ざっていないか確認する。
2. 現在ブランチを確認する。mainにいる場合は作業ブランチを切る:
   `git switch -c exp/<MilestoneID>-<短い英語slug>`(実験系)または `feat/<ID>-<slug>`(基盤系)。
3. 検証を実行する(matlab-verify Skill)。FAILがある場合は修正するか、既知問題としてPR本文に明記する。
4. 意図単位でcommitする(1コミット1意図。メッセージは日本語可、変更理由を書く)。
5. push: `git push -u origin <ブランチ名>`
6. ready PRを作成する:
   ```
   gh pr create --title "<タイトル>" --body "<本文>"
   ```
   本文テンプレート: 目的 / 変更点 / 検証結果(matlab-verifyのGate表を貼る) / 未検証範囲・既知問題
7. **ここで終了する。mergeしない。** 「PRを作成しました。内容を確認のうえ、mergeはGitHub上で行ってください」と報告し、PRのURLを伝える。

## 原則

- merge、ブランチ削除、force pushはしない(人間の判断)。
- gh未認証エラーが出たら `gh auth login` の実行をユーザーへ案内する(代行しない)。
- 検証結果を実際より良く書かない。
