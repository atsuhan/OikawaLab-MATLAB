# References — 参考文献置き場

論文・技報・規格などをためて、実験・執筆のときに参照する場所。研究Skill(`research`)の整理先。

## 構成と運用ルール

| 場所 | 中身 | git |
|---|---|---|
| `references.bib` | 書誌情報の正本(BibTeX、1文献1エントリ) | 追跡 |
| `Notes/<citekey>.md` | 文献メモ(雛形: `Notes/_template.md`) | 追跡 |
| `_local/` | PDF実体・スキャン(各自ローカル保存) | **管理外** |

- **PDFはコミットしない**(公開リポジトリのため著作権上不可)。`_local/<citekey>.pdf` に各自保存し、
  入手先リンク(DOI/arXiv URL)をNotesに書いて共有する。
- citekey は `著者名Year主題`(半角英数。例: `Schroeder1965Reverberation`)。
  BibTeXキー・Notesファイル名・PDFファイル名を一致させて紐付ける。
- メモの訂正は消さずに追記する。

## 文献の増やし方

- 手動: `references.bib` に追記 + `Notes/_template.md` をコピーして記入。
- AI: 「○○について文献を調べてReferencesに整理して」(research Skillが検索→bib追記→メモ作成まで行う)。
