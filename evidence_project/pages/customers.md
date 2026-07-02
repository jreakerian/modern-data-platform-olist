---
title: Customer Insights
description: Customer acquisition, retention, and geographic distribution
---

# 👥 Customer Insights

```sql customer_retention_all
select * from snowflake.customer_retention
```

<DateRange name=range data={customer_retention_all} dates=metric_time defaultValue="all time"/>

```sql customers_kpi
select * from snowflake.customers_kpi
```

```sql repeat_buyers_donut
select 'Customers' as grouping, 'Returning Buyers' as buyer_type, returning_customers as count from ${customers_kpi}
union all
select 'Customers' as grouping, 'One-Time Buyers' as buyer_type, total_customers - returning_customers as count from ${customers_kpi}
```

```sql customer_retention
select * from snowflake.customer_retention
where metric_time between '${inputs.range.start}' and '${inputs.range.end}'
```

```sql cohort_retention_formatted
select
  (cohort_month || '-01')::timestamp as cohort_month,
  cohort_size,
  'Month' || lpad(CAST(months_elapsed AS INTEGER)::varchar, 2, '0') || '_pct' as month_offset,
  retention_rate
from snowflake.cohort_retention
where (cohort_month || '-01') >= '${inputs.range.start}' and (cohort_month || '-01') <= '${inputs.range.end}'
```

```sql cohort_retention_pivot
PIVOT ${cohort_retention_formatted} ON month_offset USING first(retention_rate)
```

```sql customers_geo
select * from snowflake.customers_geo
```

```sql reviews_summary
select review_score::varchar as review_score, review_count from snowflake.reviews_summary
```

```sql top_cities_retention
select
    customer_city                                                                   as city,
    sum(total_customers)                                                            as total_customers,
    sum(returning_customers)                                                        as returning_customers,
    sum(total_customers * repeat_customer_rate) / nullif(sum(total_customers), 0)  as repeat_rate
from ${customer_retention}
where customer_city is not null
group by 1
order by total_customers desc
limit 20
```

## Key Customer KPIs

<BigValue
  data={customers_kpi}
  value="total_customers"
  title="Total Unique Customers"
  fmt="num0"
  comparison="avg_orders_per_customer"
  comparisonTitle="Avg Orders per Customer"
  comparisonFmt="num2"
/>

<BarChart
  data={repeat_buyers_donut}
  x="grouping"
  y="count"
  series="buyer_type"
  swapXY={true}
  type="stacked100"
  title="Repeat vs One-Time Buyers"
  chartAreaHeight=120
/>

## Cohort Retention Matrix

Customer Retention measures the percentage of each monthly customer cohort that purchases in a future month.

<CohortTable data={cohort_retention_pivot} periodTitle="Cohort Month" valueFmt="pct2"/>

## Geographic Analysis

> Use the charts below to drive two decisions: (1) **Marketing budget allocation** — cities with high customer counts but low repeat rates are acquisition-heavy markets worth doubling down on. (2) **Logistics investment** — states with high customer concentration but poor fulfillment metrics (see Order Analytics) are candidates for regional warehouse expansion.

## Top 20 Cities — Customers & Repeat Rate

<ECharts
  config={{
    dataset: { source: top_cities_retention },
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    xAxis: { type: 'value', name: 'Total Customers' },
    yAxis: { type: 'category', inverse: true },
    visualMap: {
      orient: 'horizontal',
      left: 'center',
      min: 0,
      max: 0.05,
      text: ['High Repeat Rate', 'Low Repeat Rate'],
      dimension: 'repeat_rate',
      inRange: {
        color: ['#eff6ff', '#1e3a8a']
      }
    },
    series: [
      {
        type: 'bar',
        encode: {
          x: 'total_customers',
          y: 'city',
          tooltip: ['total_customers', 'repeat_rate']
        }
      }
    ]
  }}
/>

## Customer Distribution by State

<AreaMap
  data={customers_geo}
  geoJsonUrl="/brazil-states.geojson"
  geoId="sigla"
  areaCol="customer_state"
  value="customer_count"
  title="Customers by State"
/>

## Review Score Distribution

<BarChart
  data={reviews_summary}
  x="review_score"
  y="review_count"
  swapXY={true}
  sort="review_score desc"
  yFmt="num0"
  title="Review Score Distribution"
  chartAreaHeight=250
/>
