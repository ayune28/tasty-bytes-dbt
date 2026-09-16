-- models/marts/monthly_sales_summary.sql

with fct_orders as (
    select * from {{ ref('fct_orders') }}
),

monthly_aggregation as (
    select
        -- 注文日から月の最初の日を算出
        date_trunc('month', order_date) as sales_month,
        
        -- 総売上
        sum(line_total_price) as total_sales_dollars,
        
        -- 注文件数（注文IDのユニーク数）
        count(distinct order_id) as order_count,
        
        -- 延べ購入者数（顧客IDのユニーク数）
        count(distinct customer_fk) as unique_customers,
        
        -- 平均客単価（ゼロ除算を防ぐために分母を nullif でガード）
        sum(line_total_price) / nullif(count(distinct order_id), 0) as avg_order_value_dollars

    from fct_orders
    where order_date is not null
    --月ごとに売上や注文件数を集計
    group by 1
)

select * from monthly_aggregation
order by sales_month desc