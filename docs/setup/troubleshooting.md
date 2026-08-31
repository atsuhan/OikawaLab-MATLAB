# Troubleshooting — つまずき対策

## `matlab` コマンドが見つからない

**Windows**: MATLABのインストール先(例: `C:\Program Files\MATLAB\R2025b\bin`)をPATHに追加する。
設定 → システム → バージョン情報 → システムの詳細設定 → 環境変数 → Path に追加 → ターミナル再起動。

**macOS**: シェルの設定ファイル(`~/.zshrc`)に追記する:

```bash
export PATH="/Applications/MATLAB_R2025b.app/bin:$PATH"
```

確認: `matlab -batch "disp(version)"`

## `buildtool` が失敗する

- checkcode警告: 表示されたファイル・行を修正する(警告0が合格条件)。
- テスト失敗: 失敗名と診断を読み、「このテストが失敗した。直して」とエージェントに貼るのが早い。
- `Signal Processing Toolbox` 関連のスキップ表示は正常(未導入環境ではスキップされる)。

## Codexで `index.lock: Permission denied`

Codex標準の `workspace-write` sandboxは `.git` をread-onlyにする。
このリポジトリ同梱の `.codex/config.toml`(`oikawalab-repository` プロファイル)が有効か確認する。
それでも失敗する場合のみ、`.git/index.lock` の残骸(Gitプロセスが動いていないのに存在する)を確認して削除する。

## 図の日本語が文字化けする・豆腐になる

- `GetFigureStylePreset` がOS別に日本語フォント(Yu Gothic UI / Hiragino Sans)を自動選択する。
  それでも化ける場合は候補フォントが未導入。`listfonts` で使えるフォントを確認し、
  `Functions/Plot/GetFigureStylePreset.m` の候補リストに手持ちの日本語フォントを足す。
- LinuxのCI環境では日本語フォントがなく警告が出ることがある(図の検証はローカルで行う)。

## `gh` (GitHub CLI) が未認証

```bash
gh auth login
```

ブラウザ認証で自分のGitHubアカウントにログインする(エージェントは代行しない)。

## opusモデルが使えないプラン

`.claude/agents/*.md` の `model: opus` を `model: sonnet` に書き換える([getting-started.md](getting-started.md) 補足参照)。

## 文献検索MCP(arxiv)が動かない

- `uv` が未導入: getting-started.md の表に従い導入する。
- 初回は `uvx` がパッケージを取得するため時間がかかる。ネットワーク接続を確認する。
- 使わない場合は無視してよい(必須ではない)。

## Windowsで日本語フォルダ名の実験がgitで文字化けして見える

```bash
git config core.quotepath false
```
