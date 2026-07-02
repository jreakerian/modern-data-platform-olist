-- A test fails if it returns any rows.
-- This query selects orders where the delivery date is before the purchase date, which should not happen.
SELECT
    ORDER_ID,
    ORDER_PURCHASE_TIMESTAMP,
    ORDER_DELIVERED_CUSTOMER_DATE
FROM {{ ref('fct_orders') }}
WHERE ORDER_DELIVERED_CUSTOMER_DATE < ORDER_PURCHASE_TIMESTAMP
