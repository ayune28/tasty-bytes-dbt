-- models/marts/dim_customers.sql

with fct_orders as (
    -- ファクトモデル（売上データ）から取得
    select * from {{ ref('fct_orders') }}
),

customer_summary as (
    select
        customer_fk as customer_id,
        -- 総注文回数（重複を除いた注文IDの数）
        count(distinct order_id) as total_orders,
        -- 総売上金額（顧客ごとの売上金額の合計）
        sum(line_total_price) as lifetime_value,
        -- 初回注文日と最終注文日
        min(order_date) as first_order_date,
        max(order_date) as last_order_date
    from fct_orders
    -- 顧客IDがNULLのレコードを除外
    where customer_fk is not null
    group by customer_fk
)

select * from customer_summary