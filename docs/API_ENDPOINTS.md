# API ENDPOINTS

将来のクラウド同期やリモート分析機能のために定義する、SleepSnoreApp の外部 API エンドポイント仕様です。

---

## 1. 認証

### 1.1 API 認証方式

* **Bearer Token** (例: JWT)
* リクエストヘッダー: `Authorization: Bearer <access_token>`

---

## 2. エンドポイント一覧

### 2.1 セッション管理

#### GET /api/v1/sessions

* **概要**: ユーザーのセッション一覧を取得
* **パラメータ**:

  * `start_date` (optional, `YYYY-MM-DD`): 取得開始日
  * `end_date` (optional, `YYYY-MM-DD`): 取得終了日
* **レスポンス** (200 OK):

  ```json
  [
    {
      "id": "<UUID>",
      "start_time": "<ISO8601>",
      "end_time": "<ISO8601>",
      "type": "snore" | "apnea"
    },
    ...
  ]
  ```

#### POST /api/v1/sessions

* **概要**: 新しいセッションを登録
* **リクエストボディ** (JSON):

  ```json
  {
    "start_time": "<ISO8601>",
    "end_time": "<ISO8601>",
    "type": "snore" | "apnea"
  }
  ```
* **レスポンス** (201 Created):

  ```json
  {
    "id": "<UUID>",
    "start_time": "<ISO8601>",
    "end_time": "<ISO8601>",
    "type": "snore" | "apnea"
  }
  ```

### 2.2 日次サマリー

#### GET /api/v1/daily\_summaries

* **概要**: ユーザーの日次サマリーを取得
* **パラメータ**:

  * `date` (optional, `YYYY-MM-DD`): 特定日を指定
  * `month` (optional, `YYYY-MM`): 月次データ取得
* **レスポンス** (200 OK):

  ```json
  [
    {
      "date": "YYYY-MM-DD",
      "snore_count": <number>,
      "apnea_count": <number>,
      "total_duration": <seconds>
    },
    ...
  ]
  ```

### 2.3 設定同期

#### GET /api/v1/config

* **概要**: ユーザーの設定 (ThresholdConfig) を取得
* **レスポンス** (200 OK):

  ```json
  {
    "snore_threshold": 0.5,
    "apnea_threshold": 0.5,
    "intervention_delay": 5,
    "vibration_initial": 1,
    "vibration_step": 1
  }
  ```

#### PUT /api/v1/config

* **概要**: ユーザーの設定 (ThresholdConfig) を更新
* **リクエストボディ** (JSON):

  ```json
  {
    "snore_threshold": 0.6,
    "apnea_threshold": 0.4,
    "intervention_delay": 7,
    "vibration_initial": 2,
    "vibration_step": 1
  }
  ```
* **レスポンス** (200 OK): 更新後の設定データ

---

## 3. エラーハンドリング

* **共通エラー形式** (JSON):

  ```json
  {
    "error": "<エラーメッセージ>",
    "code": <HTTPステータスコード>
  }
  ```
* 400 Bad Request, 401 Unauthorized, 404 Not Found, 500 Internal Server Error などを想定

---

> **Note**: 将来的なクラウド同期機能や Web ダッシュボード実装に向けて、上記仕様を API サーバーとすり合わせて利用してください。
