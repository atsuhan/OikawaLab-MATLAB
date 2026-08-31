# MATLAB Agentic Toolkit の導入(推奨・各自1回)

MathWorks公式の [MATLAB Agentic Toolkit](https://github.com/matlab/matlab-agentic-toolkit) を入れると、
Claude Code / Codex がMCP経由でMATLABを直接実行できるようになる(コード実行・テスト実行・静的解析、
起動中のMATLABデスクトップへの接続)。MATLABのスキル集も同梱される。

> 導入しなくても `matlab -batch` 経由でこのリポジトリは使える。導入すると対話的な解析が速く・賢くなる。

## ライセンス上の注意

- **1ユーザー1インストール。** MCPサーバーを1台立てて複数人で共有する運用は利用規約で禁止。
  共用PCでは各自のOSアカウントにそれぞれ導入する。
- 必要要件: MATLAB R2021a以降(デスクトップ接続は R2023a以降)。

## 手順(Windows / macOS 共通)

1. [Releases](https://github.com/matlab/matlab-agentic-toolkit/releases) から `agenticToolkitInstaller.mltbx` をダウンロードする。
2. MATLABでそのファイルを開く(ダブルクリック) → アドオンとしてインストールされる。
3. MATLABのコマンドウィンドウで実行:

```matlab
setupAgenticToolkit("install")
```

4. 対話プロンプトで、使うエージェント(Claude Code / Codex)と必要なスキルグループ
   (まずは Core と Signal Processing があれば十分)を選ぶ。
   インストーラがMCPサーバーの登録(ユーザースコープ)まで行う。
5. Claude Code を再起動し、MATLAB系のMCPツールが見えることを確認する。

## デスクトップMATLABに接続して使う(便利)

自分が開いているMATLABのワークスペースをエージェントと共有できる(R2023a以降):

```matlab
shareMATLABSession()
```

その状態でClaude Codeから「今のワークスペースのxをプロットして」のような指示ができる。

## 確認

Claude Code で「MATLABのバージョンをMCP経由で確認して」と頼み、バージョンが返ればOK。
うまくいかない場合は [troubleshooting.md](troubleshooting.md) へ。

> この手順書は Toolkit v0.12.0 時点(2026-08)の公式READMEに基づく。導入時は最新のREADMEも確認すること。
