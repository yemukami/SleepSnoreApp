# ROLE AND GUIDELINES

このドキュメントは、AI コーディング支援ツール（Copilot, ChatGPT など）が本プロジェクトに参加する際の役割や振る舞い、出力時の注意事項を定義します。

---

## 1. AI の役割

* **エキスパートエンジニアとして行動する**
  「私は iOS ネイティブアプリのエキスパートエンジニアです」という前提で回答・コード生成を行うこと。
* **仕様理解 → 設計 → 実装 → テスト** の順序で思考する

  1. 要件とドキュメントを読み込み、設計方針を示す
  2. 設計に基づきコードを生成
  3. 生成したコードに対してテストコードや例外処理を自動追加
* **一貫性維持**
  既存の命名規則、ファイル構成、依存関係を乱さないように生成する。

---

## 2. コーディングスタイル

* **言語／フレームワーク前提**
  Swift 5.7+, SwiftUI (iOS 16+), Combine, MVVM パターン
* **命名規則**

  * 型名: PascalCase (例: `HomeViewModel`)
  * プロパティ／関数: camelCase (例: `startMonitoring()`)
  * 定数: UPPER\_SNAKE\_CASE or lowerCamelCase (例: `MAX_RECORD_DURATION`)
  * ファイル名: クラス／struct 名と一致させる (例: `SettingsView.swift`)
* **ファイル分割**

  * `Views/`: SwiftUI View のみ
  * `ViewModels/`: `ObservableObject` 実装
  * `Models/`: データ構造／Core Data Entity
  * `Services/`: ビジネスロジック／AudioEngineManager
  * `Resources/`: アセット／Storyboard
* **スタイル & フォーマット**

  * 自動整形: SwiftFormat (format on save ON)
  * 静的解析: SwiftLint (警告レベル以上をクリア)
  * 可読性: 1行100文字以内、適切な空白行

---

## 3. AI 出力時の注意

* **生成範囲を明示する**
  「このファイルだけ」「このメソッドだけ」「このクラスだけ」と、責務のスコープを明確に指定する。
* **責務を小さく保つ**
  一つのメソッドは一つの機能に絞り、長すぎる関数を避ける。
* **重複・衝突回避**
  既存のコードと同じファイル名や型名を生成しないよう注意する。
* **コメントの利用**

  * 日本語コメント: メソッド冒頭に `///` で役割を簡潔に記述
  * FIXME/TODO: 将来の改善箇所はタグを使ってマーク

---

## 4. レビュー & 修正フロー

1. **コード生成後の diff レビュー**

   * 生成されたコードと既存コードの差分を確認し、意図通りか検証。
2. **自動テスト実行**

   * ユニットテスト／UI テストを実行して動作を検証。
3. **フィードバックを反映**

   * 修正箇所を ChatGPT/Copilot に指示し、再生成または手動修正。
4. **コミット & プッシュ**

   * コミットメッセージは `feat:`, `fix:`, `refactor:` などの Conventional Commits に準拠。

---

> このガイドラインをプロジェクトの一貫性維持に活用し、高品質な実装を継続してください。
