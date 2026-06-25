select
    region,
    state,
    city_type,
    count(distinct order_id)   as total_orders,
    sum(sales)                  as total_sales,
    sum(net_sales)               as total_net_sales,
    sum(profit)                 as total_profit,
    avg(profit_margin)          as avg_profit_margin,
    sum(quantity)                as total_quantity

from {{ ref('int_sales_enriched') }}
where is_2023 = true
group by region, state, city_type
order by total_sales desc
