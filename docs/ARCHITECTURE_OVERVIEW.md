# ARCHITECTURE OVERVIEW

本書では、SleepSnoreApp の主要コンポーネントと、それらの依存関係・データフロー、さらに処理パイプラインを示します。InputProvider レイヤーと合わせて、データ取得から判断、アクチュエーションまでの流れを可視化し、拡張性・保守性を担保する設計とします。

---

## 1. 高レベルコンポーネント図

```
┌────────────────────────────────────────────────────────────┐
│                     SleepSnoreApp                         │
│                                                            │
│  ┌───────────────────┐    ┌──────────────────────────────┐ │
│  │   InputProvider   │───▶│ AudioEngineManager           │ │
│  │ (Microphone/BLE)  │    │ (DSP + DecisionEngine +      │ │
│  └───────────────────┘    │  ActuatorController)         │ │
│            │               └──────────────────────────────┘ │
│            ▼                                        │       │
│  ┌───────────────────┐       ┌───────────────────────────┐ │
│  │ PersistenceController │◀──│ ConfigStorage             │ │
│  │   (Core Data)         │   │ (UserDefaults)            │ │
│  └───────────────────┘       └───────────────────────────┘ │
│            ▲                                        │       │
│            │                                        ▼       │
│  ┌───────────────────┐       ┌───────────────────────────┐ │
│  │    HomeViewModel  │◀─────│      HomeView             │ │
│  └───────────────────┘       └───────────────────────────┘ │
│   (Settings/Historyも同様)                                  │
└────────────────────────────────────────────────────────────┘
```

---

## 2. データフロー

1. `HomeView` の「開始」操作 → `HomeViewModel.toggleMonitoring()` 呼び出し
2. `AudioEngineManager.start(mode:)` → `InputProvider.start()` で生データ取得
3. `AudioEngineManager` がパイプラインを経由しデータ処理
4. `PersistenceController` による `Session` 保存
5. `HomeViewModel` が `@Published` 更新を受け画面をリフレッシュ
6. 設定変更時は `SettingsViewModel` → `ConfigStorage` & `AudioEngineManager.updateThresholds()` を同期
7. `HistoryViewModel.fetchSummaries()` で日次集計を取得し `HistoryView` に表示

---

## 3. 処理パイプライン

### 3.1 Acquisition (データ取得)

* **InputProvider** プロトコルを介して各種データソースを抽象化

  ```swift
  protocol InputProvider {
    var dataPublisher: AnyPublisher<RawFrame, Never> { get }
    func start()
    func stop()
  }
  ```
* 実装例: `MicrophoneInputProvider` (AVAudioEngine + AVAudioSession), `ExternalSensorInputProvider` (BLE/Wi-Fi)

### 3.2 Pre-processing (前処理)

* ノイズリダクション、正規化、特徴量抽出 (Energy, ZCR, MFCC)
* Combine の `map`/`filter` 演算子でフロー制御

### 3.3 Inference (判定)

* **DecisionEngine** プロトコルで判定ロジックを抽象化

  ```swift
  protocol DecisionEngine {
    func predict(_ features: FrameFeatures) -> Decision // .snore/.apnea/.none
  }
  ```
* 閾値モデル or Core ML モデルを差し替え可能

### 3.4 Actuation (アクチュエーション)

* **ActuatorController** プロトコルで介入機能を抽象化

  ```swift
  protocol ActuatorController {
    func trigger()
    func stop()
  }
  ```
* 実装例: `HapticActuatorController` (UIFeedbackGenerator)
* Combine の `debounce` や `sink` で介入タイミングを制御

---

## 4. 依存関係マトリクス

| コンポーネント               | 依存先                                                              |
| --------------------- | ---------------------------------------------------------------- |
| InputProvider         | (Platform-specific implementations)                              |
| DecisionEngine        | (閾値モデル or ML Model)                                              |
| ActuatorController    | UIFeedbackGenerator など                                           |
| AudioEngineManager    | InputProvider, DecisionEngine, ActuatorController, ConfigStorage |
| PersistenceController | Core Data Framework                                              |
| ConfigStorage         | Foundation (UserDefaults)                                        |
| HomeViewModel         | AudioEngineManager, PersistenceController                        |
| SettingsViewModel     | ConfigStorage, AudioEngineManager                                |
| HistoryViewModel      | PersistenceController                                            |
| SwiftUI Views         | 各 ViewModel                                                      |

---

## 5. 拡張ポイント

* **InputProvider の追加**: BLE, Wi-Fi, 外部センサーなどを容易に統合
* **DecisionEngine の入れ替え**: 将来 ML モデルやクラシカルモデルを選択可能
* **ActuatorController の拡張**: 音声/画面表示など異なる介入手段に対応
* **CloudSyncManager** の導入: PersistenceController ↔ クラウド同期

この設計を基に、各ステージを独立して実装・テストし、高い可読性と拡張性を持つシステムを構築してください。
