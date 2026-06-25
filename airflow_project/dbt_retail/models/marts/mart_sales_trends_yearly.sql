with yearly as (

    select
        order_year,
        sum(sales)          as total_sales,
        sum(net_sales)      as total_net_sales,
        sum(profit)         as total_profit,
        sum(quantity)       as total_quantity,
        count(distinct order_id) as total_orders,
        avg(profit_margin)  as avg_profit_margin

    from {{ ref('int_sales_enriched') }}
    group by order_year

),

with_yoy as (

    select
        *,
        lag(total_sales) over (order by order_year)  as prev_year_sales,
        round(
            (total_sales - lag(total_sales) over (order by order_year))
            / nullif(lag(total_sales) over (order by order_year), 0) * 100
        , 2) as yoy_growth_pct

    from yearly

)

select * from with_yoy
order by order_year
