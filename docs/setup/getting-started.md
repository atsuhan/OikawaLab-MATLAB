# Getting Started — 最初の15分

MATLABに不慣れでも大丈夫。この手順どおりに進めれば、AIに指示して解析が回る状態になる。

## 1. 必要なもの

| ツール | 入手先 | 確認コマンド |
|---|---|---|
| MATLAB (R2023a以降推奨) | 大学のライセンスポータル | `matlab -batch "disp(version)"` |
| Git | Windows: `winget install Git.Git` / macOS: `xcode-select --install` | `git --version` |
| Claude Code または Codex | https://claude.com/claude-code | `claude --version` |
| GitHubアカウント | https://github.com | — |
| uv (任意: 文献検索MCP用) | Windows: `winget install astral-sh.uv` / macOS: `brew install uv` | `uv --version` |

`matlab` コマンドが見つからない場合は [troubleshooting.md](troubleshooting.md) へ。

## 2. リポジトリを手に入れる

1. GitHubでこのリポジトリを開き、**Use this template → Create a new repository** で自分のリポジトリを作る(名前例: `MATLABResearch-<名字>`)。
2. clone する:

```bash
git clone https://github.com/<あなたのアカウント>/<リポジトリ名>.git
```

## 3. 動作確認

リポジトリのフォルダで:

```bash
matlab -batch "buildtool"
```

数分待って「** test の完了」で終わればOK(checkcode警告0 + 全テストPASS)。

## 4. Claude Code を起動する

リポジトリのフォルダで `claude` を起動する。初回に `.mcp.json`(文献検索)の承認を聞かれたら許可してよい。

## 5. 最初の一言(コピペOK)

- 「Sampleのデモ実験を動かして、図を見せて」
- 「新しい実験を始めたいです。○○を測定したデータを解析します」
- 「今の進捗をSTATUS.mdにまとめて」

**エージェントから質問されたら答えてください。** わからない項目は「わからない」と答えれば、安全な既定値と選択肢を提示してくれます。

## 6. やってはいけないこと3つ

1. **PRのmergeボタンを押す前に内容を確認する**(エージェントはPR作成までしかしない設計)。
2. **`Input/` の生データを消さない・上書きしない**(測り直せないデータは戻らない)。
3. **「できました」を鵜呑みにしない** — 報告のGate/Result/Evidence表を見る。UNVERIFIEDは未検証の意味。

## 次のステップ

- MATLABとの連携を強化する(推奨): [matlab-agentic-toolkit.md](matlab-agentic-toolkit.md)
- 自分のタスクを台帳に登録する: 「MILESTONESに私のタスクを追加して」と頼む

## 補足: モデルについて

`.claude/agents/` の各エージェントはモデル指定済み(教授・設計系=opus、実装=sonnet、雑務=haiku)。
契約プランにopusが含まれない場合は、該当ファイルの `model: opus` を `model: sonnet` に書き換えてよい(動作は変わらず、レビューの深さが少し変わる)。
