-- models/staging/stg_orders.sql

with source as (
    -- 生データ（raw_pos.order_header）から直接取得
    select * from {{ source('raw_pos', 'order_header') }}
),

renamed as (
    select
        -- 主キー（注文ID）
        order_id as order_pk,
        
        -- 外部キー（トラックID、顧客ID、ロケーションID）
        truck_id as truck_fk,
        customer_id as customer_fk,
        location_id as location_fk,
        
        -- 注文チャネル（Web、モバイルアプリ、店頭など）
        order_channel,
        
        -- 注文日時
        order_ts as order_timestamp,
        
        -- 注文日（日付型にキャストして集計しやすく加工）
        to_date(order_ts) as order_date
        
    from source
)

select * from renamed