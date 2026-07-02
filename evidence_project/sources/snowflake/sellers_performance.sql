-- Seller performance from gold mart
SELECT
    seller_id,
    seller_city,
    seller_state,
    total_sales_value,
    total_orders_fulfilled,
    average_freight_value,
    average_fulfillment_days
FROM OLIST_LAKEHOUSE_PROD.PROD_GOLD.dim_sellers
ORDER BY total_sales_value DESC
