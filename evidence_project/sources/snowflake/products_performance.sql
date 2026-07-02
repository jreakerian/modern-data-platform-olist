-- Product performance from gold mart
SELECT
    product_id,
    product_category_name_english AS category,
    total_units_sold,
    total_revenue_generated,
    average_review_score,
    total_reviews
FROM OLIST_LAKEHOUSE_PROD.PROD_GOLD.dim_products
WHERE total_units_sold > 0
ORDER BY total_revenue_generated DESC
