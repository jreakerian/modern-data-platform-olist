with

source as (

    select * from {{ source('raw_bronze', 'olist_order_items_dataset') }}

),

renamed as (

    select
        order_id::varchar as order_id,
        order_item_id::number as order_item_id,
        product_id::varchar as product_id,
        seller_id::varchar as seller_id,
        shipping_limit_date::timestamp_ntz as shipping_limit_date,
        price::number(10,2) as price,
        freight_value::number(10,2) as freight_value

    from source
    qualify row_number() over (
        partition by order_id, order_item_id
        order by shipping_limit_date desc
    ) = 1

)

select * from renamed
