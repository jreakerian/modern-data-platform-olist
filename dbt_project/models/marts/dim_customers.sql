WITH CUSTOMERS AS (
    SELECT * FROM {{ ref('stg_olist_customers') }}
),

ORDERS AS (
    SELECT * FROM {{ ref('stg_olist_orders') }}
),

-- Aggregate order metrics per physical customer (customer_unique_id),
-- bridging through customer_id since orders only carry customer_id.
CUSTOMER_ORDERS AS (
    SELECT
        C.CUSTOMER_UNIQUE_ID,
        MIN(O.ORDER_PURCHASE_TIMESTAMP) AS FIRST_ORDER_DATE,
        MAX(O.ORDER_PURCHASE_TIMESTAMP) AS MOST_RECENT_ORDER_DATE,
        COUNT(O.ORDER_ID) AS NUMBER_OF_ORDERS
    FROM CUSTOMERS AS C
    LEFT JOIN ORDERS AS O ON C.CUSTOMER_ID = O.CUSTOMER_ID
    GROUP BY C.CUSTOMER_UNIQUE_ID
),

-- Collapse the staging customers table to one row per unique person.
-- customer_zip_code_prefix, city, and state are taken from the most
-- recently seen customer record to reflect the latest known address.
DEDUPED_CUSTOMERS AS (
    SELECT
        CUSTOMER_UNIQUE_ID,
        CUSTOMER_ZIP_CODE_PREFIX,
        CUSTOMER_CITY,
        CUSTOMER_STATE,
        ROW_NUMBER() OVER (
            PARTITION BY CUSTOMER_UNIQUE_ID
            ORDER BY CUSTOMER_ZIP_CODE_PREFIX DESC
        ) AS RN
    FROM CUSTOMERS
)

SELECT
    DC.CUSTOMER_UNIQUE_ID,
    DC.CUSTOMER_ZIP_CODE_PREFIX,
    DC.CUSTOMER_CITY,
    DC.CUSTOMER_STATE,
    CO.FIRST_ORDER_DATE,
    CO.MOST_RECENT_ORDER_DATE,
    COALESCE(CO.NUMBER_OF_ORDERS, 0) AS NUMBER_OF_ORDERS
FROM DEDUPED_CUSTOMERS AS DC
LEFT JOIN CUSTOMER_ORDERS AS CO ON DC.CUSTOMER_UNIQUE_ID = CO.CUSTOMER_UNIQUE_ID
WHERE DC.RN = 1
