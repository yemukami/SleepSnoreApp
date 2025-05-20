# TEST PLAN

本ドキュメントでは、SleepSnoreApp のユニットテストおよび UI テストのカバレッジとテストフローを定義します。テスト自動化を通じて品質を担保し、リグレッションを防止することを目的とします。

---

## 1. テスト戦略

* **ユニットテスト**: ビジネスロジックやアルゴリズム層（DecisionEngine, InputProvider のモック, PersistenceController）の振る舞いを検証。
* **UI テスト**: SwiftUI の画面遷移や主要操作（開始/停止、設定変更、履歴表示）を end-to-end で検証。
* **モック/スタブの利用**: ネットワーク、ファイル I/O、音声入力はモック化して deterministic なテストを実現。
* **CI 連携**: GitHub Actions などでプルリクエスト時に自動実行。

---

## 2. ユニットテスト

### 2.1 DecisionEngine テスト

* **テスト内容**: 閾値モデルによる判定ロジック（Energy, ZCR, 周期）
* **ケース**:

  * 正常系: いびき音サンプル → `.snore` を返す
  * 正常系: 呼吸ノイズサンプル → `.apnea` を返す
  * 異常系: 無音・雑音サンプル → `.none` を返す
* **テストファイル**: `DecisionEngineTests.swift`

### 2.2 InputProvider テスト

* **テスト内容**: モックデータを用いてデータPublisher が正しく開始/停止するか
* **ケース**:

  * `start()` 呼び出し → データストリームが `NonEmpty` になる
  * `stop()` 呼び出し → データストリームが終了
* **テストファイル**: `MicrophoneInputProviderTests.swift`

### 2.3 PersistenceController テスト

* **テスト内容**: `Session` の保存・取得・日次集計
* **ケース**:

  * `saveContext()` 後の `Session` が fetch で取得できる
  * `fetchRequestDailySummaries()` が正しい集計結果を返す
* **テストファイル**: `PersistenceControllerTests.swift`

### 2.4 ConfigStorage テスト

* **テスト内容**: UserDefaults への設定保存と読み込み
* **ケース**:

  * `saveThresholdConfig()` → `loadThresholdConfig()` が同じ値を返す
  * `saveDataCollectionMode(true)` → `loadDataCollectionMode()` が `true`
* **テストファイル**: `ConfigStorageTests.swift`


### 2.5 ActuatorController テスト
- **テスト内容**: HapticActuatorController が `trigger()` で振動を発生、`stop()` で停止 
- **ケース**:
  - `trigger()` 呼び出し → UIFeedbackGenerator の `impactOccurred()` が呼ばれる
  - `stop()` 呼び出し → 継続的振動が停止する（MockGenerator で検証）
- **テストファイル**: `ActuatorControllerTests.swift`
---

## 3. UI テスト

### 3.1 HomeView フロー

* **テスト内容**: モード切替・開始・停止ボタン操作
* **シナリオ**:

  1. HomeView 起動 → 初期状態は「検知モード」「停止」
  2. モードを「介入モード」に切替
  3. 「開始」タップ → ステータスが「検知中…」に変わる
  4. 「停止」タップ → ステータスが「待機中」に戻る
* **テストファイル**: `HomeViewUITests.swift`

### 3.2 SettingsView フロー

* **テスト内容**: 設定値の変更と反映
* **シナリオ**:

  1. SettingsView 起動 → デフォルト値が表示される
  2. スライダー／ステッパーを動かし値を変更
  3. 画面を閉じて再度開く → 変更が保持されていること
* **テストファイル**: `SettingsViewUITests.swift`

### 3.3 HistoryView フロー

* **テスト内容**: 日次サマリーの表示とセクション展開
* **シナリオ**:

  1. HistoryView 起動 → 過去のサマリーがリスト表示される
  2. 「詳細を見る」タップ → DayDetailView が表示される
* **テストファイル**: `HistoryViewUITests.swift`

---

## 4. テスト環境設定

* 各テストターゲットに **Mock** モード用の DI を設定し、実機・シミュレータで動作可能
* **CI 設定例** (GitHub Actions):

  ```yaml
  jobs:
    test:
      runs-on: macos-latest
      steps:
        - uses: actions/checkout@v2
        - name: Set up Ruby
          uses: ruby/setup-ruby@v1
        - name: Install dependencies
          run: bundle install
        - name: Run tests
          run: xcodebuild test -scheme SleepSnoreApp -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.0'
  ```

  

---

> このテストプランに従って、ユニットテストおよび UI テストを実装し、CI で自動化してください。
