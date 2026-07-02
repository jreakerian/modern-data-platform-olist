WITH customer_first_orders AS (
    SELECT
        CUSTOMER_UNIQUE_ID,
        DATE_TRUNC('month', FIRST_ORDER_DATE::date) AS cohort_month
    FROM OLIST_LAKEHOUSE_PROD.PROD_GOLD.DIM_CUSTOMERS
),
customer_all_orders AS (
    SELECT
        map.CUSTOMER_UNIQUE_ID,
        DATE_TRUNC('month', ord.ORDER_PURCHASE_TIMESTAMP::date) AS order_month
    FROM OLIST_LAKEHOUSE_PROD.PROD_GOLD.FCT_ORDERS ord
    JOIN OLIST_LAKEHOUSE_PROD.PROD_SILVER.STG_OLIST_CUSTOMERS map
        ON ord.CUSTOMER_ID = map.CUSTOMER_ID
),
cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT CUSTOMER_UNIQUE_ID) AS cohort_size
    FROM customer_first_orders
    GROUP BY 1
),
retention AS (
    SELECT
        f.cohort_month,
        o.order_month,
        DATEDIFF('month', f.cohort_month, o.order_month) AS months_elapsed,
        COUNT(DISTINCT o.CUSTOMER_UNIQUE_ID) AS returning_customers
    FROM customer_first_orders f
    JOIN customer_all_orders o
        ON f.CUSTOMER_UNIQUE_ID = o.CUSTOMER_UNIQUE_ID
    GROUP BY 1, 2, 3
)
SELECT
    TO_VARCHAR(r.cohort_month, 'YYYY-MM') AS cohort_month,
    r.months_elapsed,
    r.returning_customers,
    s.cohort_size,
    r.returning_customers::float / s.cohort_size AS retention_rate
FROM retention r
JOIN cohort_sizes s
    ON r.cohort_month = s.cohort_month
WHERE r.months_elapsed >= 0
ORDER BY r.cohort_month, r.months_elapsed;
