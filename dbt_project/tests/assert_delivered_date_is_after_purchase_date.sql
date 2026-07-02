-- A test fails if it returns any rows.
-- This query selects orders where the delivery date is before the purchase date, which should not happen.
select
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date
from {{ ref('fct_orders') }}
where order_delivered_customer_date < order_purchase_timestamp
