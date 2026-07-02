with

source as (

    select * from {{ source('raw_bronze', 'olist_order_reviews_dataset') }}

),

renamed as (

    select
        review_id::varchar as review_id,
        order_id::varchar as order_id,
        review_score::number as review_score,
        review_comment_title::varchar as review_comment_title,
        review_comment_message::varchar as review_comment_message,
        review_creation_date::timestamp_ntz as review_creation_date,
        review_answer_timestamp::timestamp_ntz as review_answer_timestamp

    from source
    qualify row_number() over (
        partition by review_id
        order by review_creation_date desc
    ) = 1

)

select * from renamed
