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
    print("--- Top 20 rows of customers_geo ---")
    cs.execute("""
        SELECT customer_state, customer_city, COUNT(*), SUM(number_of_orders)
        FROM dim_customers
        GROUP BY customer_state, customer_city
        ORDER BY COUNT(*) DESC
        LIMIT 20
    """)
    for row in cs.fetchall():
        print(f"State: {row[0]}, City: {repr(row[1])}, Count: {row[2]}")
finally:
    cs.close()
    ctx.close()
