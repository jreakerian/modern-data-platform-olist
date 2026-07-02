-- Monthly customer retention from the semantic layer export
SELECT
    metric_time__month AS metric_time,
    customer_unique_id__customer_city AS customer_city,
    total_customers,
    returning_customers,
    repeat_customer_rate
FROM OLIST_LAKEHOUSE_PROD.PROD_GOLD.customer_retention_summary
ORDER BY metric_time