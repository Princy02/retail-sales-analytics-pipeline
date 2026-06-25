with source as (

    select * from {{ source('raw', 'store_sales') }}

),

cleaned as (

    select
        order_id,
        customer_id,
        customer_name,
        last_name,
        cast(order_date as date)                       as order_date,
        cast(ship_date as date)                         as ship_date,
        cast(sales_date as date)                        as sales_date,
        ship_mode,
        segment,
        outlet_type,
        city_type,
        region,
        state,
        country,
        postal_code,
        product_id,
        category,
        sub_category,
        product_name,
        cast(sales as float)                            as sales,
        cast(quantity as integer)                       as quantity,
        cast(discount as float)                         as discount,
        cast(profit as float)                           as profit,
        cast(year as integer)                           as year,
        date_part('month', order_date)                  as order_month,
        date_part('quarter', order_date)                as order_quarter

    from source
    where order_id is not null

)

select * from cleaned
