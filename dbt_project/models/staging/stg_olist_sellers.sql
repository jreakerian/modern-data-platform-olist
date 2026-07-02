with

source as (

    select * from {{ source('raw_bronze', 'olist_sellers_dataset') }}

),

renamed as (

    select
        seller_id::varchar as seller_id,
        seller_zip_code_prefix::varchar as seller_zip_code_prefix,
        seller_city::varchar as seller_city,
        seller_state::varchar as seller_state

    from source
    qualify row_number() over (
        partition by seller_id
        order by seller_id
    ) = 1

)

select * from renamed
