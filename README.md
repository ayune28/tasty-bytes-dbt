# Tasty Bytes データ基盤プロジェクト

## このプロジェクトについて
ECおよびフードトラック事業の運営を想定し、「どの顧客が優良顧客か」「月ごとの売上はどう推移しているか」を分析するためのデータ基盤です。
生の注文・顧客データをSnowflake上でdbtを使って整形し、マーケティング施策や経営判断に使える分析用テーブルを作成しています。

### 想定する利用シーン
- リピート顧客への優先的な施策（クーポン配布やメルマガ）のターゲット抽出
- 月次の売上・購入者数の推移をモニタリングし、異常な変動に早く気づく

## データフロー
生データ（Snowflake: raw_pos）
↓ ソース定義（source）
ステージング層（stg_orders, stg_order_detail）
↓ 整形・カラム名の統一
マート層（dim_customers, fct_orders）
↓ ビジネスロジックの付与
分析用テーブル（monthly_sales_summary）

## モデル一覧

| モデル名 | 層 | 説明 |
|---|---|---|
| stg_orders | staging | 生の注文データを整形 |
| stg_order_detail | staging | 生の注文詳細データを整形 |
| dim_customers | marts | 顧客ごとの情報を集計・整理 |
| fct_orders | marts | 注文データのファクトテーブル |
| monthly_sales_summary | marts | 月次の注文件数・売上・客単価を集計 |

## 補足：このテーブルの作り方と環境について
今回のプロジェクトでは、Snowflakeとdbt Coreを使用してデータモデルを構築しています。
また、Python（Pandasおよびsnowflake-connector-python）を用いてSnowflakeからデータを安全に抽出（RSA秘密鍵による公開鍵認証を採用）し、
API連携やBIツール連携できそうかの確認をしています。

## データ品質の担保（検証）
構築したデータやモデルの信頼性を保つため、以下の仕組みで品質を担保しています。

### 1. dbtテストによる自動チェック（`staging.yml`）
システム的なエラーやデータの破損を防ぐため、主要なモデルに対して `dbt test` を実行し、以下の項目を自動で検証しています。
- **一意性（unique）**: 注文IDなどに重複がないか
- **非NULL（not_null）**: 注文IDや顧客ID、合計金額などの必須カラムに空欄が混ざっていないか

### 2. Snowflakeでの手動検証
dbtのテストではカバーしきれない、集計ロジックの妥当性を以下のSQLで個別に検証しています。

**① 月の重複チェック**
`monthly_sales_summary` の `sales_month` が二重計上されていないかを確認するクエリなどを実行し、データの整合性を担保しています。

```sql
SELECT
    sales_month,
    COUNT(*) AS row_count
FROM
    tb_101.raw_pos.monthly_sales_summary
GROUP BY sales_month
HAVING COUNT(*) > 1;
```sql

##  使用環境
- **DWH**: Snowflake (`tb_101`)
- **データ変換**: dbt
- **言語**: Python (pandas, snowflake-connector)
- **環境**: VS Code, Git
- **認証**: 秘密鍵 (`rsa_key.p8`)
- **データ**: Tasty Bytes (`raw_pos`スキーマ)