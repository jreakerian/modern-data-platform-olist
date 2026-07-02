---
title: Olist E-Commerce Analytics
description: Executive dashboard powered by the dbt Semantic Layer
queries:
  - orders_all_time.sql
  - orders_totals.sql
  - orders_daily.sql
---

# 🏪 Olist E-Commerce Analytics

<DateRange name=range data={orders_all_time} dates=metric_time defaultValue="all time"/>

<Alert status="info">
  This dashboard is powered by dbt's MetricFlow Semantic Layer, exported to Snowflake, and rendered with Evidence.dev.
  Data refreshes on each deployment via GitHub Actions.
</Alert>

## Key Performance Indicators

<BigValue
  data={orders_totals}
  value="total_orders"
  title="Total Orders"
  fmt="num0"
  comparison="average_order_value"
  comparisonTitle="Avg Order Value"
  comparisonFmt="usd2"
/>

<BigValue
  data={orders_totals}
  value="total_revenue"
  title="Total Revenue"
  fmt="usd0"
  comparison="fulfillment_rate"
  comparisonTitle="Fulfillment Rate"
  comparisonFmt="pct1"
/>

<BigValue
  data={orders_totals}
  value="average_fulfillment_days"
  title="Avg Delivery Days"
  fmt="num1"
/>

## Revenue Trend

<LineChart
  data={orders_daily}
  x="metric_time"
  y="total_revenue"
  yFmt="usd0"
  title="Daily Revenue"
  chartAreaHeight=300
  echartsOptions={{ textStyle: { fontFamily: 'Playfair Display' } }}
/>

## Order Volume by Status

<BarChart
  data={orders_daily}
  x="metric_time"
  y="total_orders"
  series="order_status"
  title="Daily Orders by Status"
  chartAreaHeight=300
  echartsOptions={{ textStyle: { fontFamily: 'Playfair Display' } }}
/>

---

**Navigation:** [Order Analytics](/orders) · [Customer Insights](/customers) · [Product & Sellers](/products) · [Data Quality](/data-quality)