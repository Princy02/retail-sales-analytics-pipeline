select
    order_year,
    category,
    sub_category,
    count(distinct order_id)  as total_orders,
    sum(sales)                  as total_sales,
    sum(profit)                 as total_profit,
    avg(profit_margin)          as avg_profit_margin,
    sum(quantity)                as total_quantity

from {{ ref('int_sales_enriched') }}
group by order_year, category, sub_category
order by order_year, total_sales desc
