with

source as (

    select * from {{ source('raw_bronze', 'olist_order_payments_dataset') }}

),

renamed as (

    select
        order_id::varchar as order_id,
        payment_sequential::number as payment_sequential,
        payment_type::varchar as payment_type,
        payment_installments::number as payment_installments,
        payment_value::number(10,2) as payment_value

    from source
    qualify row_number() over (
        partition by order_id, payment_sequential
        order by order_id
    ) = 1

)

select * from renamed
