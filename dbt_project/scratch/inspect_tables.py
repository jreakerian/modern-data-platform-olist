import os
import snowflake.connector

# Connect to Snowflake using the credentials from profiles.yml
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
    for table in ['customer_retention_summary', 'daily_order_performance', 'daily_items_and_gmv']:
        print(f"--- Columns for {table} ---")
        cs.execute(f"DESCRIBE TABLE {table}")
        for row in cs.fetchall():
            print(f"  {row[0]} ({row[1]})")
finally:
    cs.close()
    ctx.close()
