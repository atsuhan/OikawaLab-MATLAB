---
name: matlab-verify
description: リポジトリの検証ゲート(buildtool)を実行し、Gate/Result/Evidence表でPASS/FAIL/UNVERIFIEDを厳密に報告する。実装後・commit前・「検証して」「テストして」の依頼で使用する。
---

# matlab-verify

## 手順

1. 検証対象を確認する。実験フォルダの変更なら、その実験もcheckcode対象に含めるか判断する。
2. 静的解析: `matlab -batch "buildtool check"` を実行する。
   - 実験フォルダも対象にする場合: `matlab -batch "addpath('Tests/tools'); RunAllChecks({'Projects/<実験フォルダ>'})"`
3. テスト: `matlab -batch "buildtool test"` を実行する。
4. 追加ゲートを確認する:
   - `git status` で `Input/` 配下・一次データ(.wav/.mat)に差分がないこと。
   - `Functions/` を変更した場合、対応するテストが追加・更新されていること。
   - 図を生成した場合、check-figures Skill での確認状況。
5. 結果を必ず次の表で報告する:

| Gate | Result | Evidence |
|---|---|---|
| buildtool check (checkcode警告0) | PASS / FAIL / UNVERIFIED | (実行コマンドと要約行) |
| buildtool test (全テスト) | PASS / FAIL / UNVERIFIED | (件数と失敗名) |
| 一次データ無変更 | PASS / FAIL / UNVERIFIED | (git statusの該当行) |
| Functions変更時のテスト同時更新 | PASS / N/A / UNVERIFIED | (対象テスト名) |
| 図品質 (check-figures) | PASS / N/A / UNVERIFIED | (確認した画像数) |

## 原則

- 実行していないゲートは必ず UNVERIFIED と書く。PASSは実行した証拠がある場合のみ。
- buildtool の PASS を、実データでの妥当性・図の品質・実験結果の正しさと同一視しない。
- FAILを修正した場合は、該当ゲートを再実行してから報告する。
