-- models/staging/stg_order_detail.sql

with source as (
    -- 生データ（raw_pos.order_detail）から直接取得
    select * from {{ source('raw_pos', 'order_detail') }}
),

renamed as (
    select
        -- 主キー（注文明細ID）
        order_detail_id as order_detail_pk,
        
        -- 外部キー（注文ID、メニューアイテムID）
        order_id as order_fk,
        menu_item_id as menu_item_fk,
        
        -- 数量
        quantity,
        
        -- 単価
        unit_price
        
    from source
)

select * from renamed