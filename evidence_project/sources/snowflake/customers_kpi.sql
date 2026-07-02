-- Lifetime customer KPI totals sourced directly from dim_customers.
-- This is the correct source for BigValue KPI cards because:
-- 1. dim_customers is deduped to one row per physical person (customer_unique_id).
-- 2. The customer_retention_summary export is bucketed by month x city and is
--    NOT safe to aggregate into a single lifetime total (count_distinct is non-additive).
SELECT
    COUNT(*)                                                AS total_customers,
    COUNT(CASE WHEN number_of_orders > 1 THEN 1 END)       AS returning_customers,
    ROUND(
        COUNT(CASE WHEN number_of_orders > 1 THEN 1 END)
        / COUNT(*),
        4
    )                                                       AS repeat_customer_rate,
    AVG(number_of_orders)                                   AS avg_orders_per_customer
FROM OLIST_LAKEHOUSE_PROD.PROD_GOLD.dim_customers
