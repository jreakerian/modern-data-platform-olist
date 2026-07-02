{% snapshot scd_sellers %}

    {{
        config(
            target_schema='snapshots',
            unique_key='seller_id',
            strategy='check',
            check_cols=['seller_zip_code_prefix', 'seller_city', 'seller_state'],
            invalidate_hard_deletes=True,
        )
    }}

    SELECT
        SELLER_ID,
        SELLER_ZIP_CODE_PREFIX,
        SELLER_CITY,
        SELLER_STATE
    FROM {{ ref('stg_olist_sellers') }}

{% endsnapshot %}
