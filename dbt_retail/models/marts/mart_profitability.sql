select
    category,
    case
        when discount = 0 then 'No Discount'
        when discount <= 0.15 then 'Low (0-15%)'
        when discount <= 0.30 then 'Medium (15-30%)'
        else 'High (30-50%)'
    end as discount_band,
    count(distinct order_id) as total_orders,
    sum(sales)                 as total_sales,
    sum(profit)                as total_profit,
    avg(profit_margin)         as avg_profit_margin

from {{ ref('int_sales_enriched') }}
group by category, discount_band
order by category, discount_band
