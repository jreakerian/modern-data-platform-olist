-- Daily items and GMV from the semantic layer export
SELECT
    metric_time__day AS metric_time,
    total_items_sold,
    total_gmv
FROM OLIST_LAKEHOUSE_PROD.PROD_GOLD.daily_items_and_gmv
ORDER BY metric_time