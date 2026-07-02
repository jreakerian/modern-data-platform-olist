WITH customers AS (
    SELECT * FROM {{ ref('stg_olist_customers') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_olist_orders') }}
),

-- Aggregate order metrics per physical customer (customer_unique_id),
-- bridging through customer_id since orders only carry customer_id.
customer_orders AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_order_date,
        MAX(o.order_purchase_timestamp) AS most_recent_order_date,
        COUNT(o.order_id)               AS number_of_orders
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
),

-- Collapse the staging customers table to one row per unique person.
-- customer_zip_code_prefix, city, and state are taken from the most
-- recently seen customer record to reflect the latest known address.
deduped_customers AS (
    SELECT
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        ROW_NUMBER() OVER (
            PARTITION BY customer_unique_id
            ORDER BY customer_zip_code_prefix DESC
        ) AS rn
    FROM customers
)

SELECT
    dc.customer_unique_id,
    dc.customer_zip_code_prefix,
    dc.customer_city,
    dc.customer_state,
    co.first_order_date,
    co.most_recent_order_date,
    COALESCE(co.number_of_orders, 0) AS number_of_orders
FROM deduped_customers dc
LEFT JOIN customer_orders co ON dc.customer_unique_id = co.customer_unique_id
WHERE dc.rn = 1
