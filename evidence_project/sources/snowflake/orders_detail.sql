-- Direct query on gold mart for detailed order analysis
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_delivered_customer_date,
    total_price,
    total_freight_value,
    number_of_items,
    total_payment_value,
    DATEDIFF('day', order_purchase_timestamp, order_delivered_customer_date) AS delivery_days
FROM OLIST_LAKEHOUSE_PROD.PROD_GOLD.fct_orders
