# Functions Reference

> このファイルは `Tests/tools/GenFunctionsIndex.m` により生成されます。直接編集しないでください。

Functions配下の関数: 27件 / H1欠落: 0件

## Analysis

| Function | Summary | Source |
|---|---|---|
| `ApplyBandpassFilter` | ゼロ位相バンドパスフィルタ (butter + filtfilt) | [source](../Functions/Analysis/ApplyBandpassFilter.m) |
| `ComputeFftSpectrum` | 片側振幅スペクトルを計算する (窓補正込み・スケーリング規約固定) | [source](../Functions/Analysis/ComputeFftSpectrum.m) |
| `ComputeSpectrogram` | STFTパワースペクトログラムを計算する (Toolbox非依存) | [source](../Functions/Analysis/ComputeSpectrogram.m) |
| `ConvertDbToPa` | 音圧レベル SPL [dB] を音圧 [Pa] へ変換する (基準 20 µPa) | [source](../Functions/Analysis/ConvertDbToPa.m) |
| `ConvertPaToDb` | 音圧 [Pa] を音圧レベル SPL [dB] へ変換する (基準 20 µPa) | [source](../Functions/Analysis/ConvertPaToDb.m) |
| `EstimateReverbTime` | インパルス応答から残響時間を推定する (Schroeder逆積分法) | [source](../Functions/Analysis/EstimateReverbTime.m) |
| `GenerateWindow` | 窓関数と振幅補正係数を返す (Toolbox非依存の数式実装) | [source](../Functions/Analysis/GenerateWindow.m) |
| `GetAWeightingDb` | 周波数ごとのA特性重み [dB] を返す (IEC 61672-1) | [source](../Functions/Analysis/GetAWeightingDb.m) |
| `GetSoundSpeed` | 気温 [degC] から空気中の音速 [m/s] を返す | [source](../Functions/Analysis/GetSoundSpeed.m) |

## Core

| Function | Summary | Source |
|---|---|---|
| `EnsureFolder` | フォルダが存在しなければ作成し、パスをそのまま返す | [source](../Functions/Core/EnsureFolder.m) |
| `FindRepoRoot` | リポジトリルートの絶対パスを返す | [source](../Functions/Core/FindRepoRoot.m) |
| `HashArrays` | 複数配列を size 情報込みで正準化し SHA-256 (小文字16進64文字) を返す | [source](../Functions/Core/HashArrays.m) |
| `LoadCacheMat` | SaveCacheMat で保存したキャッシュmatを読み込む | [source](../Functions/Core/LoadCacheMat.m) |
| `RunCached` | 入力ハッシュが一致すればキャッシュを返し、なければ計算して保存する | [source](../Functions/Core/RunCached.m) |
| `SaveCacheMat` | キャッシュ用matファイルを inputHash 付きで保存する | [source](../Functions/Core/SaveCacheMat.m) |
| `SetupProjectPaths` | 「Functions + 当該実験のみ」に MATLAB path を整える | [source](../Functions/Core/SetupProjectPaths.m) |
| `TimestampString` | ファイル名用タイムスタンプ 'yyyyMMdd-HHmmss' を返す | [source](../Functions/Core/TimestampString.m) |
| `WriteExportManifest` | Export成果物とParamsハッシュをmanifest.jsonへ記録する | [source](../Functions/Core/WriteExportManifest.m) |

## IO

| Function | Summary | Source |
|---|---|---|
| `GenerateSyntheticImpulseResponse` | 残響時間が既知の合成インパルス応答を生成する | [source](../Functions/IO/GenerateSyntheticImpulseResponse.m) |
| `GenerateTestSignal` | テスト・デモ用の合成信号を生成する | [source](../Functions/IO/GenerateTestSignal.m) |
| `LoadAudioFile` | 音声ファイルを読み込む (audioread ラッパー、単位規約つき) | [source](../Functions/IO/LoadAudioFile.m) |
| `SaveAudioFile` | 音声ファイルを書き出す (audiowrite ラッパー、クリップ検査つき) | [source](../Functions/IO/SaveAudioFile.m) |

## Plot

| Function | Summary | Source |
|---|---|---|
| `ApplyFigureStyle` | 図全体に研究室標準スタイルを一括適用する | [source](../Functions/Plot/ApplyFigureStyle.m) |
| `CollectExports` | 実験のExport図をReportsフォルダへ収集し、出所を記録する | [source](../Functions/Plot/CollectExports.m) |
| `ExportFigure` | 図をタイムスタンプ付きで Export フォルダへ書き出す | [source](../Functions/Plot/ExportFigure.m) |
| `GetColorPalette` | 研究室標準のカラーパレット [N x 3] RGB(0-1) を返す | [source](../Functions/Plot/GetColorPalette.m) |
| `GetFigureStylePreset` | 図スタイルプリセット定義の単一正本 | [source](../Functions/Plot/GetFigureStylePreset.m) |

