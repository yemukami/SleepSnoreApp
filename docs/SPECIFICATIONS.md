# SPECIFICATIONS

本ファイルでは、SleepSnoreApp の画面仕様、データモデル、サービスインターフェースをまとめます。

---

## 1. 画面仕様

### 1.1 HomeView (睡眠モニタリング画面)

| UI 要素       | 型              | ViewModel バインディング          | 説明                                   |
| ----------- | -------------- | -------------------------- | ------------------------------------ |
| モード切替セグメント  | Picker         | `$mode: MonitorMode`       | `検知`／`介入` を切り替え                      |
| 開始／停止ボタン    | Button         | `isMonitoring`             | タップで `start(mode:)` / `stop()` を呼び出す |
| ステータステキスト   | Text           | `statusText`               | `待機中`、`検知中…`、`介入中…`                  |
| 継続時間表示      | Text           | `currentSessionDuration`   | `TimeInterval` を `formatted()` で表示   |
| いびき回数／無呼吸回数 | Texts/HStack   | `snoreCount`, `apneaCount` | 回数カウンター                              |
| ナビゲーションリンク  | NavigationLink | –                          | 履歴画面／設定画面への遷移                        |

---

### 1.2 SettingsView (設定画面)

| UI 要素        | 型       | ViewModel バインディング           | 説明                 |
| ------------ | ------- | --------------------------- | ------------------ |
| いびき感度スライダー   | Slider  | `$config.snoreThreshold`    | 0.0 〜 1.0 の範囲      |
| 無呼吸感度スライダー   | Slider  | `$config.apneaThreshold`    | 0.0 〜 1.0 の範囲      |
| 介入遅延設定       | Stepper | `$config.interventionDelay` | 1 〜 10 秒           |
| 初期振動強度設定     | Stepper | `$config.vibrationInitial`  | 0 〜 10             |
| 振動ステップ幅設定    | Stepper | `$config.vibrationStep`     | 1 〜 5              |
| データ収集モード トグル | Toggle  | `$isDataCollectionMode`     | 開発用データ収集機能の ON/OFF |

---

### 1.3 HistoryView (履歴確認画面)

| UI 要素      | 型              | ViewModel バインディング                | 説明                                 |
| ---------- | -------------- | -------------------------------- | ---------------------------------- |
| 日付ごとのセクション | List / Section | `dailySummaries: [DailySummary]` | 日付タイトル下に集計結果を表示                    |
| いびき回数      | Text / HStack  | `day.snoreCount`                 | その日のいびき回数                          |
| 無呼吸回数      | Text / HStack  | `day.apneaCount`                 | その日の無呼吸回数                          |
| 合計継続時間     | Text / HStack  | `day.totalDuration`              | `TimeInterval` を `formatted()` で表示 |
| 詳細表示リンク    | NavigationLink | `DayDetailView`                  | セッションごとのタイムライン詳細へ遷移                |

---

## 2. データモデル

### 2.1 Core Data Entity: `Session`

| 属性名       | 型     | 説明                                   |
| --------- | ----- | ------------------------------------ |
| id        | UUID  | プライマリキー                              |
| startTime | Date  | 検知開始時刻                               |
| endTime   | Date  | 検知終了時刻                               |
| typeRaw   | Int16 | `SessionType` (`0=snore`, `1=apnea`) |

#### Enum: `SessionType`

```swift
enum SessionType: Int16 {
  case snore = 0
  case apnea = 1
}
```

### 2.2 Struct: `DailySummary`

| プロパティ         | 型            | 説明     |
| ------------- | ------------ | ------ |
| date          | Date         | 集計日    |
| snoreCount    | Int          | いびき回数  |
| apneaCount    | Int          | 無呼吸回数  |
| totalDuration | TimeInterval | 合計継続時間 |

### 2.3 Struct: `ThresholdConfig`

| プロパティ             | 型      | 説明                     |
| ----------------- | ------ | ---------------------- |
| snoreThreshold    | Double | いびき検知エネルギー閾値 (0.0〜1.0) |
| apneaThreshold    | Double | 無呼吸検知エネルギー閾値 (0.0〜1.0) |
| interventionDelay | Int    | 検知後の介入遅延時間 (秒)         |
| vibrationInitial  | Int    | 初期バイブレーション強度           |
| vibrationStep     | Int    | 振動強度増分ステップ数            |


## 2.4 InputProvider / DecisionEngine / ActuatorController

### InputProvider (Protocol)
- メソッド: `start()`, `stop()`
- プロパティ: `dataPublisher: AnyPublisher<RawFrame, Never>`

### DecisionEngine (Protocol)
- メソッド: `predict(_ features: FrameFeatures) -> Decision`

### ActuatorController (Protocol)
- メソッド: `trigger()`, `stop()`
---

## 3. サービスインターフェース

### 3.1 AudioEngineManager

```swift
class AudioEngineManager: ObservableObject {
  @Published var snoreCount: Int
  @Published var apneaCount: Int
  @Published var currentDuration: TimeInterval
  @Published var statusText: String
  var isDataCollectionMode: Bool

  func start(mode: MonitorMode)
  func stop()
  func updateThresholds(_ config: ThresholdConfig)
}
```

* **start(mode:)**: マイク録音・DSP閾値判定・セッション保存・介入トリガを実装
* **stop()**: 録音停止・状態リセット
* **updateThresholds(\_:)**: 設定画面と同期して閾値／介入パラメータを更新

### 3.2 PersistenceController

```swift
struct PersistenceController {
  var container: NSPersistentContainer
  func saveContext()
  static func fetchRequestDailySummaries() -> NSFetchRequest<DailySummary>
}
```

### 3.3 ConfigStorage

```swift
struct ConfigStorage {
  static func loadThresholdConfig() -> ThresholdConfig
  static func saveThresholdConfig(_ config: ThresholdConfig)
  static func loadDataCollectionMode() -> Bool
  static func saveDataCollectionMode(_ flag: Bool)
}
```

---

## 4. ナビゲーション構造

```
NavigationView
 └── HomeView
      ├── NavigationLink("履歴") → HistoryView
      └── NavigationLink("設定") → SettingsView
```

---

## 5. 将来の拡張（システム要件反映）

* HealthKit 連携
* CSV/PDF エクスポート
* ML モデル推論モジュールを AudioEngineManager に組み込み
* プッシュ通知

この仕様をもとに、コーディングAI に各コンポーネントの実装を依頼してください。
