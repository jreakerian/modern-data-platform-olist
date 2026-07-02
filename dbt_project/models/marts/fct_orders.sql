{{
    config(
        materialized='incremental',
        incremental_strategy='microbatch',
        unique_key='order_id',
        event_time='order_purchase_timestamp',
        batch_size='day',
        begin='2016-09-01',
        on_schema_change='append_new_columns'
    )
}}

WITH orders AS (
    -- dbt handles filtering automatically for microbatch if stg_olist_orders has event_time configured
    SELECT * FROM {{ ref('stg_olist_orders') }}
),

orders_items AS (
    SELECT
        order_id,
        SUM(price) AS total_price,
        SUM(freight_value) AS total_freight_value,
        COUNT(order_item_id) AS number_of_items
    FROM {{ ref('stg_olist_order_items') }}
    GROUP BY order_id
),

order_payments AS (
    SELECT
        order_id,
        total_amount AS total_payment_value
    FROM {{ ref('int_order_payments_pivoted')}}
),

final AS (
    SELECT
        orders.order_id,
        orders.customer_id,
        orders.order_status,
        orders.order_purchase_timestamp,
        orders.order_delivered_customer_date,
        orders.order_estimated_delivery_date,
        COALESCE(orders_items.total_price, 0) AS total_price,
        COALESCE(orders_items.total_freight_value, 0) AS total_freight_value,
        COALESCE(orders_items.number_of_items, 0) AS number_of_items,
        COALESCE(order_payments.total_payment_value, 0) AS total_payment_value
    FROM orders
    LEFT JOIN orders_items ON orders.order_id = orders_items.order_id
    LEFT JOIN order_payments ON orders.order_id = order_payments.order_id
)

SELECT * FROM final
