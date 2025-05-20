# ARCHITECTURE OVERVIEW

本書では、SleepSnoreApp の主要コンポーネントと、それらの依存関係・データフローを図示します。プロジェクト全体の構造を把握し、拡張や保守の際に参照してください。

---

## 1. 高レベルコンポーネント図

```
┌───────────────────────────────────────────┐
│               SleepSnoreApp               │
│                                           │
│   ┌────────────┐      ┌───────────────┐  │
│   │ HomeView   │◀─────│ HomeViewModel │  │
│   └────────────┘      └───────────────┘  │
│        │                       │          │
│        ▼                       ▼          │
│   ┌────────────┐      ┌────────────────┐ │
│   │ SettingsView│◀────│ SettingsViewModel││
│   └────────────┘      └────────────────┘ │
│        │                       │          │
│        ▼                       ▼          │
│   ┌────────────┐      ┌────────────────┐ │
│   │ HistoryView │◀────│ HistoryViewModel ││
│   └────────────┘      └────────────────┘ │
│                                           │
│              ▲                            │
│              │                            │
│   ┌─────────────────────────────────┐     │
│   │     AudioEngineManager         │     │
│   │  (AVAudioEngine + DSP/Threshold)│     │
│   └─────────────────────────────────┘     │
│              ▲                            │
│              │                            │
│   ┌─────────────────────────────────┐     │
│   │  PersistenceController (Core Data) │   │
│   └─────────────────────────────────┘     │
│              ▲                            │
│              │                            │
│   ┌─────────────────────────────────┐     │
│   │       ConfigStorage (UserDefaults) │   │
│   └─────────────────────────────────┘     │
└───────────────────────────────────────────┘
```

* **View (SwiftUI)**: `HomeView`、`SettingsView`、`HistoryView` など。UI レイヤー。
* **ViewModel**: 各 View に対応し、`@Published` でデータバインディング。
* **AudioEngineManager**: 音声キャプチャ＋閾値判定＋セッション管理＋介入制御。
* **PersistenceController**: Core Data ストアの管理、`Session` エンティティの CRUD と日次集計。
* **ConfigStorage**: ユーザー設定（ThresholdConfig、DataCollectionMode）の永続化。

---

## 2. データフロー

1. ユーザー操作 (`HomeView` の「開始」) → `HomeViewModel.toggleMonitoring()` 呼び出し
2. `AudioEngineManager.start(mode:)` で録音開始 → フレームごとに DSP/閾値判定 → `snoreCount`/`apneaCount` 更新
3. イベント終了時に `Session` エンティティを `PersistenceController` 経由で保存
4. `HistoryViewModel.fetchSummaries()` で `Session.fetchRequestDailySummaries()` を呼び、集計結果を ViewModel に渡して画面表示
5. 設定変更 (`SettingsView` ) → `SettingsViewModel.saveConfig()` → `ConfigStorage` と `AudioEngineManager.updateThresholds(_:)` を同期

---

## 3. 依存関係マトリクス

| コンポーネント               | 依存先                                       |
| --------------------- | ----------------------------------------- |
| HomeViewModel         | AudioEngineManager, PersistenceController |
| SettingsViewModel     | ConfigStorage, AudioEngineManager         |
| HistoryViewModel      | PersistenceController                     |
| AudioEngineManager    | ConfigStorage                             |
| PersistenceController | CoreData Framework                        |
| ConfigStorage         | Foundation (UserDefaults)                 |
| Views (SwiftUI)       | ViewModels                                |

---

## 4. 拡張ポイント

* **ML モデルモジュール**: `AudioEngineManager` の判断ロジックを機械学習モデルに差し替え可能
* **HealthKitService**: `Services/HealthKitService.swift` を追加し、HealthKit 連携を行う
* **CloudSyncManager**: `Services/CloudSyncManager.swift` で Core Data とクラウドの同期を実装

この概要をもとに、アーキテクチャの全体感を把握し、各コンポーネント実装やリファクタリングを進めてください。
