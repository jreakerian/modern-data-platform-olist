-- This test reconciles the aggregated sales metrics in dim_products back to the original grain in stg_olist_order_items.
-- It ensures that no units sold or revenues are lost or double-counted during the aggregation in the mart.

WITH MART_SUMMARY AS (
    SELECT
        SUM(TOTAL_UNITS_SOLD) AS MART_UNITS_SOLD,
        SUM(TOTAL_REVENUE_GENERATED) AS MART_REVENUE
    FROM {{ ref('dim_products') }}
),

STAGING_SUMMARY AS (
    SELECT
        COUNT(*) AS STAGING_UNITS_SOLD,
        SUM(PRICE) AS STAGING_REVENUE
    FROM {{ ref('stg_olist_order_items') }}
)

SELECT *
FROM MART_SUMMARY AS M
CROSS JOIN STAGING_SUMMARY AS S
WHERE
    M.MART_UNITS_SOLD <> S.STAGING_UNITS_SOLD
    OR ABS(M.MART_REVENUE - S.STAGING_REVENUE) > 0.01
