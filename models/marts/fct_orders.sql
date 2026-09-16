-- models/marts/fct_orders.sql

with stg_orders as (
    select * from {{ ref('stg_orders') }}
),

stg_order_detail as (
    select * from {{ ref('stg_order_detail') }}
),

final as (
    select

        -- 注文情報（stg_order_detail側で変更したpk名に合わせる）
        d.order_detail_pk as order_detail_id, 
        o.order_pk as order_id,
        o.customer_fk,
        o.truck_fk,
        o.location_fk,
        o.order_channel,
        o.order_timestamp,
        o.order_date,
        
        -- 明細ごとの数量・金額
        d.quantity,
        d.unit_price,

        -- 売上金額
        d.quantity * d.unit_price as line_total_price

    from stg_orders o
    -- 注文明細と結合
    inner join stg_order_detail d
        on o.order_pk = d.order_fk 
)

select * from final