目的：アプリの“システム要件”を一元管理


 # システム要件

以下では、本アプリ（SleepSnoreApp）の **開発環境** と **使用言語**、それを前提とした **コーディング時の注意事項** を整理します。

---

## 1. 開発環境 (アプリ提供先)

| 項目          | 値/仕様                             |
| ----------- | -------------------------------- |
| プラットフォーム    | iOS                              |
| 対応 OS バージョン | iOS 16.0 以上                      |
| 対応デバイス      | iPhone シリーズ（iPhone 8 以降推奨）       |
| バックグラウンド録音  | AVAudioSession を利用し、ロック画面も録音継続   |
| ストレージ       | Core Data (SQLite)               |
| テスト環境       | iOS Simulator (iPhone 14), 実機テスト |
| デバッグ        | Xcode 15.x                       |
| 継続時間テスト     | 常時録音（8時間以上）の長時間安定稼働              |

---

## 2. 使用言語・フレームワーク

| 項目           | バージョン/ライブラリ                                 |
| ------------ | ------------------------------------------- |
| 言語           | Swift 5.7 以上                                |
| UI フレームワーク   | SwiftUI (iOS 16+ 向け)                        |
| リアクティブ       | Combine                                     |
| オーディオ処理      | AVFoundation (AVAudioEngine／AVAudioSession) |
| 永続化          | Core Data                                   |
| DI / アーキテクチャ | MVVM                                        |
| テスト          | XCTest / XCUITest                           |
| フォーマッター      | SwiftFormat                                 |
| スタイルリント      | SwiftLint                                   |

---

## 3. コーディング時の注意事項

### 3.1 一般方針

* **メインスレッドをブロックしない**: 音声処理や DB 操作はバックグラウンドキューで実行し、UI 更新のみメインスレッドで行う。
* **MVVM + Combine**: ViewModel 側でビジネスロジックを保持し、@Published で View にバインド。
* **依存の注入**: AudioEngineManager、PersistenceController、ConfigStorage はシングルトンまたは DI コンテナを用いて注入。

### 3.2 命名規則

* **型名**: PascalCase  (例: `AudioEngineManager`, `SessionViewModel`)
* **プロパティ／関数**: camelCase  (例: `startMonitoring()`, `snoreCount`)
* **定数**: lowerCamelCase または全大文字スネーク (例: `defaultThreshold`, `MAX_RECORD_TIME`)
* **ファイル名**: タイプと同一 (例: `HomeView.swift`, `ThresholdConfig.swift`)

### 3.3 ファイル分割

* **Views/**: SwiftUI の View 定義のみ
* **ViewModels/**: `ObservableObject` を conform したクラス
* **Models/**: データ構造 (`struct`／Core Data Entity)
* **Services/**: 音声エンジン／永続化／設定管理などの処理ロジック
* **Resources/**: Storyboard／画像アセット

### 3.4 スタイル & フォーマッティング

* **SwiftFormat** で自動整形 (`format on save` ON)
* **SwiftLint** ルールは厳格度: warning レベル以上を守る
* 1 行 100 文字以内、改行位置は SwiftFormat 標準に従う

### 3.5 エラーハンドリング

* `try?`・`try!` の多用は禁止。必ず `do-catch` で明示的にキャッチし、ログまたは UI フィードバックを実装。
* 不可逆なエラー（例: Core Data の保存失敗）はクラッシュせず、ユーザー通知 or リトライロジックを検討。

### 3.6 テスト

* **ユニットテスト**: ビジネスロジック（Threshold 判定、セッション集計など）を XCTest でカバー
* **UI テスト**: XCUITest で主要画面のフロー（開始→検知→介入→サマリー表示）を自動化

### 3.7 ドキュメント

* コード内の `///` 形式のドキュメンテーションコメントを活用し、Xcode Quick Help を充実
* API 定義や設計に変更があった際は、`docs/SYSTEM_REQUIREMENTS.md` を更新

---

この要件を遵守しつつ、安定・高品質なアプリ開発を進めてください。
