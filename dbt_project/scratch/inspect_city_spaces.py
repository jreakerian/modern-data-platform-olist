import os
import snowflake.connector

ctx = snowflake.connector.connect(
    user='CASHALOT1',
    password='gXZ!CE25mHy!:Fr',
    account='FOFOXOE-EEB51968',
    warehouse='COMPUTE_WH',
    database='OLIST_LAKEHOUSE_PROD',
    role='OLIST_ROLE',
    schema='PROD_GOLD'
)

cs = ctx.cursor()
try:
    print("--- Searching for duplicates with different spaces/casing in same state ---")
    cs.execute("""
        WITH grouped AS (
            SELECT customer_state, customer_city, COUNT(*) as cnt
            FROM dim_customers
            GROUP BY customer_state, customer_city
        )
        SELECT 
            customer_state, 
            TRIM(LOWER(customer_city)) as clean_city, 
            COUNT(*) as unique_groups,
            ARRAY_AGG(customer_city) as original_names
        FROM grouped
        GROUP BY customer_state, clean_city
        HAVING COUNT(*) > 1
        ORDER BY unique_groups DESC
        LIMIT 20
    """)
    rows = cs.fetchall()
    if not rows:
        print("No duplicates found with spaces/casing differences in the same state.")
    for row in rows:
        print(f"State: {row[0]}, Clean City: {repr(row[1])}, Unique Groups: {row[2]}, Originals: {row[3]}")
finally:
    cs.close()
    ctx.close()
