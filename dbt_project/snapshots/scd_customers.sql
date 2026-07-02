{% snapshot scd_customers %}

    {{
        config(
            target_schema='snapshots',
            unique_key='customer_id',
            strategy='check',
            check_cols=['customer_zip_code_prefix', 'customer_city', 'customer_state'],
            invalidate_hard_deletes=True,
        )
    }}

    SELECT
        CUSTOMER_ID,
        CUSTOMER_UNIQUE_ID,
        CUSTOMER_ZIP_CODE_PREFIX,
        CUSTOMER_CITY,
        CUSTOMER_STATE
    FROM {{ ref('stg_olist_customers') }}

{% endsnapshot %}
