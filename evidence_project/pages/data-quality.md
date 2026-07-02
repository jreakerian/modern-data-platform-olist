---
title: Data Quality
description: Data freshness, volume trends, and pipeline health
queries:
  - orders_all_time.sql
  - orders_daily.sql
  - items_daily.sql
  - review_quality.sql
  - review_kpis.sql
---

# 🛡️ Data Quality & Pipeline Health

<DateRange name=range data={orders_all_time} dates=metric_time defaultValue="all time"/>

<Alert status="info">
  Detailed anomaly detection results are available in the
  <a href="https://your-elementary-report-url-here" target="_blank" rel="noopener">Elementary Data Quality Report</a>.
  Replace this link with your hosted Elementary HTML report URL once deployed.
</Alert>

## Daily Data Volume Trend

<LineChart
  data={orders_daily}
  x="metric_time"
  y="total_orders"
  yFmt="num0"
  title="Daily Order Volume (anomaly detection baseline)"
  chartAreaHeight=300
  echartsOptions={{ textStyle: { fontFamily: 'Playfair Display' } }}
/>

## Revenue Consistency Check

<LineChart
  data={orders_daily}
  x="metric_time"
  y="average_order_value"
  yFmt="usd2"
  title="AOV Stability Over Time"
  chartAreaHeight=250
  echartsOptions={{ textStyle: { fontFamily: 'Playfair Display' } }}
/>

## Items vs GMV Correlation

<ScatterPlot
  data={items_daily}
  x="total_items_sold"
  y="total_gmv"
  xFmt="num0"
  yFmt="usd0"
  title="Items Sold vs GMV (each point = 1 day)"
  chartAreaHeight=300
  echartsOptions={{ textStyle: { fontFamily: 'Playfair Display' } }}
/>

## Review Quality Monitoring

<BigValue
  data={review_kpis}
  value="total_reviews"
  title="Total Reviews"
  fmt="num0"
  comparison="negative_reviews"
  comparisonTitle="Negative (1-2 star)"
  comparisonFmt="num0"
/>

<BigValue
  data={review_kpis}
  value="negative_review_rate"
  title="Negative Review Rate"
  fmt="pct2"
  comparison="average_review_score"
  comparisonTitle="Avg Score"
  comparisonFmt="num2"
/>

<LineChart
  data={review_quality}
  x="metric_time"
  y="negative_reviews"
  y2="negative_review_rate"
  yFmt="num0"
  y2Fmt="pct1"
  title="Daily Negative Reviews: Volume vs Rate"
  chartAreaHeight=250
  echartsOptions={{ textStyle: { fontFamily: 'Playfair Display' } }}
/>

<LineChart
  data={review_quality}
  x="metric_time"
  y="average_review_score"
  yFmt="num2"
  title="Average Review Score Trend"
  chartAreaHeight=250
  echartsOptions={{ textStyle: { fontFamily: 'Playfair Display' } }}
/>

## Pipeline Architecture

This dashboard is powered by:
- **Sources:** 9 external tables on S3 → Snowflake (`RAW_BRONZE`)
- **Staging:** 9 deduplicated views (`SILVER`) with schema contracts
- **Marts:** 6 tables (`GOLD`) — 3 fact, 3 dimension
- **Semantic Layer:** 20 MetricFlow metrics, 5 saved queries exported to Snowflake
- **Observability:** Elementary anomaly detection on all mart models
- **Orchestration:** Airflow DAG with S3 sensor → external table refresh → dbt build → tests → Elementary report
- **BI:** This Evidence.dev dashboard, hosted on GitHub Pages

---

**Navigation:** [Executive Overview](/) · [Order Analytics](/orders) · [Customer Insights](/customers) · [Product & Sellers](/products)