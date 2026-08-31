# App — App Designer アプリ置き場

対話的なツール(計測GUI、データビューア等)をApp Designerで作る場合はここに置く。

- 1アプリ1フォルダ: `App/<AppName>/`(.mlapp と付属ファイル一式)
- アプリ内のロジックは薄く保ち、計算は `Functions/` の関数を呼ぶ(テスト可能性のため)
- .mlapp はバイナリでdiffが読めないため、変更内容はcommitメッセージに書く
