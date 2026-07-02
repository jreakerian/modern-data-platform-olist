---
title: Product & Seller Performance
description: Top products, categories, and seller metrics
---

# 🏷️ Product & Seller Performance

```sql products_performance
select * from snowflake.products_performance
```

```sql sellers_performance
select * from snowflake.sellers_performance
```

## Top 20 Product Categories by Revenue

```sql top_categories
SELECT
    category,
    SUM(total_revenue_generated) AS revenue,
    SUM(total_units_sold) AS units,
    AVG(average_review_score) AS avg_score
FROM ${products_performance}
GROUP BY category
ORDER BY revenue DESC
LIMIT 20
```

<BarChart
  data={top_categories}
  x="category"
  y="revenue"
  yFmt="usd0"
  title="Revenue by Product Category"
  chartAreaHeight=350
  swapXY=true
/>

<DataTable
  data={products_performance}
  rows=25
  search=true
>
  <Column id="category" title="Category" />
  <Column id="total_units_sold" title="Units Sold" fmt="num0" />
  <Column id="total_revenue_generated" title="Revenue" fmt="usd2" />
  <Column id="average_review_score" title="Avg Review" fmt="num2" />
  <Column id="total_reviews" title="Reviews" fmt="num0" />
</DataTable>

```sql top_sellers_by_state
SELECT
    seller_state,
    COUNT(*) AS seller_count,
    SUM(total_sales_value) AS total_sales,
    AVG(average_fulfillment_days) AS avg_fulfillment
FROM ${sellers_performance}
GROUP BY seller_state
ORDER BY total_sales DESC
```

<BarChart
  data={top_sellers_by_state}
  x="seller_state"
  y="total_sales"
  yFmt="usd0"
  title="Total Sales by Seller State"
  chartAreaHeight=300
/>

<DataTable
  data={sellers_performance}
  rows=25
  search=true
>
    <Column id="seller_city" title="City" />
    <Column id="seller_state" title="State" />
    <Column id="total_sales_value" title="Total Sales" fmt="usd2" />
    <Column id="total_orders_fulfilled" title="Orders" fmt="num0" />
    <Column id="average_fulfillment_days" title="Avg Delivery Days" fmt="num1" />
</DataTable>