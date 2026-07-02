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

WITH ORDERS AS (
    -- dbt handles filtering automatically for microbatch if stg_olist_orders has event_time configured
    SELECT * FROM {{ ref('stg_olist_orders') }}
),

ORDERS_ITEMS AS (
    SELECT
        ORDER_ID,
        SUM(PRICE) AS TOTAL_PRICE,
        SUM(FREIGHT_VALUE) AS TOTAL_FREIGHT_VALUE,
        COUNT(ORDER_ITEM_ID) AS NUMBER_OF_ITEMS
    FROM {{ ref('stg_olist_order_items') }}
    GROUP BY ORDER_ID
),

ORDER_PAYMENTS AS (
    SELECT
        ORDER_ID,
        TOTAL_AMOUNT AS TOTAL_PAYMENT_VALUE
    FROM {{ ref('int_order_payments_pivoted') }}
),

FINAL AS (
    SELECT
        ORDERS.ORDER_ID,
        ORDERS.CUSTOMER_ID,
        ORDERS.ORDER_STATUS,
        ORDERS.ORDER_PURCHASE_TIMESTAMP,
        ORDERS.ORDER_DELIVERED_CUSTOMER_DATE,
        ORDERS.ORDER_ESTIMATED_DELIVERY_DATE,
        COALESCE(ORDERS_ITEMS.TOTAL_PRICE, 0) AS TOTAL_PRICE,
        COALESCE(ORDERS_ITEMS.TOTAL_FREIGHT_VALUE, 0) AS TOTAL_FREIGHT_VALUE,
        COALESCE(ORDERS_ITEMS.NUMBER_OF_ITEMS, 0) AS NUMBER_OF_ITEMS,
        COALESCE(ORDER_PAYMENTS.TOTAL_PAYMENT_VALUE, 0) AS TOTAL_PAYMENT_VALUE
    FROM ORDERS
    LEFT JOIN ORDERS_ITEMS ON ORDERS.ORDER_ID = ORDERS_ITEMS.ORDER_ID
    LEFT JOIN ORDER_PAYMENTS ON ORDERS.ORDER_ID = ORDER_PAYMENTS.ORDER_ID
)

SELECT * FROM FINAL
