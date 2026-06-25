with stg as (

    select * from {{ ref('stg_store_sales') }}

),

enriched as (

    select
        *,
        date_part('year', order_date)                          as order_year,
        case when date_part('year', order_date) = 2023 then true else false end as is_2023,
        profit / nullif(sales, 0)                              as profit_margin,
        sales * (1 - discount)                                 as net_sales,
        case
            when order_month in (1,2,3)  then 'Q1'
            when order_month in (4,5,6)  then 'Q2'
            when order_month in (7,8,9)  then 'Q3'
            else 'Q4'
        end as quarter_label

    from stg

)

select * from enriched
