-- Customer geographic distribution
SELECT
    customer_state,
    customer_city,
    COUNT(*) AS customer_count,
    SUM(number_of_orders) AS total_orders,
    AVG(number_of_orders) AS avg_orders_per_customer
FROM OLIST_LAKEHOUSE_PROD.PROD_GOLD.dim_customers
GROUP BY customer_state, customer_city
ORDER BY customer_count DESC
