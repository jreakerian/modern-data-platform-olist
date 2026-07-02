with

source as (

    select * from {{ source('raw_bronze', 'product_category_name_translation') }}

),

renamed as (

    select
        product_category_name::varchar as product_category_name,
        product_category_name_english::varchar as product_category_name_english

    from source
    qualify row_number() over (
        partition by product_category_name
        order by product_category_name
    ) = 1

)

select * from renamed
