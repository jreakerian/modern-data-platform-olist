-- Review score distribution
SELECT
    review_score,
    COUNT(*) AS review_count
FROM OLIST_LAKEHOUSE_PROD.PROD_GOLD.fct_customer_reviews
GROUP BY review_score
ORDER BY review_score