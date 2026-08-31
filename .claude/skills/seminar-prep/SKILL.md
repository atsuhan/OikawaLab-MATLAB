---
name: seminar-prep
description: ゼミ発表・中間発表の下書き資料をReports/へ生成する。「ゼミ資料を作って」「発表準備」「スライドの下書き」の依頼で使用する。
---

# seminar-prep

## 手順

1. 対象を確認する: どの実験か、発表日、種別(ゼミ発表/進捗報告/中間発表/卒論)、持ち時間。曖昧なら AskUserQuestion でまとめて確認する。
2. 材料を収集する:
   - 対象実験の `README.md`(目的・条件・結果メモ)と `docs/roadmap/MILESTONES.md` の該当項目
   - 図: `CollectExports` で `Reports/YYYYMMDD_種別_テーマ/` へ収集する
     `matlab -batch "addpath(genpath('Functions')); CollectExports({'Projects/<実験>'}, 'Reports/<フォルダ>')"`
3. `Reports/<フォルダ>/memo.md` に固定構成で下書きを書く(雛形: `Reports/_template/memo.md`):
   背景 / 目的 / 方法(条件表) / 結果(使用図と読み取り) / 考察 / 課題 / 次回までにやること
4. **数値・主張の扱い:**
   - 検証済みの数値のみ書く。未検証は「(未検証)」を明記する。
   - 各図の下に出所(実験名とparamsHashの先頭8桁)を書く(sources.jsonから転記)。
5. **professor Agentにレビューを1周依頼**し、指摘とゼミ質問をmemo.md末尾の「想定質問」節へ反映してから学生へ返す。
6. 報告: 生成場所、構成、professorの主な指摘、発表前に埋めるべき穴。

## 原則

- スライド化(PowerPoint等)は学生の作業または別依頼。このSkillは材料(memo.md + assets/)を完成させるまで。
- 証拠のない成果・数値を書かない。
