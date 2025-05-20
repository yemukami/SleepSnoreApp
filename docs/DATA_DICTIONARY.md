# DATA DICTIONARY

SleepSnoreApp で扱う主要データモデルのキーと型をまとめます。Core Data エンティティや Swift の構造体、および将来の JSON API 連携用キーも掲載しています。

---

## 1. Core Data Entity: Session

| 属性名       | 型     | 説明                                    |
| --------- | ----- | ------------------------------------- |
| id        | UUID  | 一意識別子（プライマリキー）                        |
| startTime | Date  | いびき／無呼吸検知開始時刻                         |
| endTime   | Date  | 検知終了時刻                                |
| typeRaw   | Int16 | `SessionType` 値（0 = snore, 1 = apnea） |

**SessionType (Enum)**

```swift
enum SessionType: Int16 {
  case snore = 0
  case apnea = 1
}
```

---

## 2. Struct: DailySummary

| プロパティ         | 型            | 説明             |
| ------------- | ------------ | -------------- |
| date          | Date         | 集計対象の日付        |
| snoreCount    | Int          | その日のいびき発生回数    |
| apneaCount    | Int          | その日の無呼吸発生回数    |
| totalDuration | TimeInterval | いびき＋無呼吸の合計継続時間 |

---

## 3. Struct: ThresholdConfig

| プロパティ             | 型      | 説明                     |
| ----------------- | ------ | ---------------------- |
| snoreThreshold    | Double | いびき検知エネルギー閾値 (0.0〜1.0) |
| apneaThreshold    | Double | 無呼吸検知エネルギー閾値 (0.0〜1.0) |
| interventionDelay | Int    | 介入開始までの待機時間 (秒)        |
| vibrationInitial  | Int    | 初回バイブレーション強度           |
| vibrationStep     | Int    | 振動強度増分ステップ             |

---

## 4. JSON API 用キー (将来の拡張)

### 4.1 Session オブジェクト

```json
{
  "id": "UUID文字列",
  "start_time": "ISO8601 タイムスタンプ",
  "end_time": "ISO8601 タイムスタンプ",
  "type": "snore" | "apnea"
}
```

### 4.2 DailySummary オブジェクト

```json
{
  "date": "YYYY-MM-DD",
  "snore_count": 5,
  "apnea_count": 2,
  "total_duration": 75.0   // 秒
}
```

### 4.3 ThresholdConfig オブジェクト

```json
{
  "snore_threshold": 0.5,
  "apnea_threshold": 0.5,
  "intervention_delay": 5,
  "vibration_initial": 1,
  "vibration_step": 1
}
```

## 5. Internal Types

### RawFrame
| プロパティ | 型        | 説明                    |
|-----------|-----------|-------------------------|
| timestamp | Date      | サンプリング時刻        |
| samples   | [Float]   | PCM 16kHz／20ms バッファ|

### FrameFeatures
| プロパティ | 型      | 説明                        |
|-----------|---------|-----------------------------|
| energy    | Double  | 短時間エネルギー            |
| zcr       | Double  | ゼロ交差率                  |
| mfcc      | [Double]| MFCC 係数リスト             |

> **Note**: JSON スキーマは今後クラウド同期や外部連携を行う際に使用します。
