with

source as (

    select * from {{ source('raw_bronze', 'olist_geolocation_dataset') }}

),

renamed as (

    select
        geolocation_zip_code_prefix::varchar as geolocation_zip_code_prefix,
        geolocation_lat::number(10,8) as geolocation_lat,
        geolocation_lng::number(11,8) as geolocation_lng,
        geolocation_city::varchar as geolocation_city,
        geolocation_state::varchar as geolocation_state

    from source
    qualify row_number() over (
        partition by geolocation_zip_code_prefix, geolocation_lat, geolocation_lng
        order by geolocation_zip_code_prefix
    ) = 1

)

select * from renamed
