---
title: Order Analytics
description: Deep dive into order trends, revenue, fulfillment, and logistics performance
queries:
  - orders_all_time.sql
  - orders_daily.sql
  - items_daily.sql
  - basket_size.sql
  - order_kpis.sql
---

# 📦 Order Analytics

<DateRange name=range data={orders_all_time} dates=metric_time defaultValue="all time"/>

## Key Order KPIs

```sql orders_last_30
select * from ${orders_daily}
order by metric_time desc
limit 30
```

<div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8 mt-4">
  <!-- Growth Metrics Card -->
  <div class="p-6 bg-gray-50 border border-gray-200 rounded-xl shadow-sm">
    <h3 class="text-xs font-bold text-gray-500 uppercase tracking-widest mb-4 border-b border-gray-200 pb-2">Primary Growth Metrics</h3>
    <Grid cols=2>
      <div>
        <BigValue
          data={order_kpis}
          value="total_orders"
          title="Total Orders"
          fmt="num0"
          comparison="delivered_orders"
          comparisonTitle="Delivered"
          comparisonFmt="num0"
        />
        <div class="mt-3 text-[10px] text-gray-400 font-semibold uppercase tracking-wider">30-Day Trend</div>
        <Sparkline data={orders_last_30} dateCol="metric_time" valueCol="total_orders" color="#9ca3af" height="25" />
      </div>

      <div>
        <BigValue
          data={order_kpis}
          value="total_revenue"
          title="Total Revenue"
          fmt="usd0"
        />
        <div class="mt-2 text-sm text-gray-500 font-medium border-l-2 border-gray-300 pl-3">
          AOV: <span class="font-bold text-gray-700"><Value data={order_kpis} column="average_order_value" fmt="usd2"/></span>
        </div>
        <div class="mt-3 text-[10px] text-gray-400 font-semibold uppercase tracking-wider">30-Day Trend</div>
        <Sparkline data={orders_last_30} dateCol="metric_time" valueCol="total_revenue" color="#9ca3af" height="25" />
      </div>
    </Grid>
  </div>

  <!-- Operational Efficiency Card -->
  <div class="p-6 bg-gray-50 border border-gray-200 rounded-xl shadow-sm">
    <h3 class="text-xs font-bold text-gray-500 uppercase tracking-widest mb-4 border-b border-gray-200 pb-2">Operational Efficiency</h3>
    <Grid cols=2>
      <div>
        <BigValue
          data={order_kpis}
          value="fulfillment_rate"
          title="Fulfillment Rate"
          fmt="pct1"
          comparison="undelivered_orders"
          comparisonTitle="Undelivered"
          comparisonFmt="num0"
        />
        <div class="mt-3 text-[10px] text-gray-400 font-semibold uppercase tracking-wider">30-Day Trend</div>
        <Sparkline data={orders_last_30} dateCol="metric_time" valueCol="fulfillment_rate" color="#9ca3af" height="25" />
      </div>

      <div>
        <BigValue
          data={order_kpis}
          value="late_delivery_rate"
          title="Late Delivery Rate"
          fmt="pct1"
          comparison="late_deliveries"
          comparisonTitle="Late Orders"
          comparisonFmt="num0"
          downIsGood={true}
        />
        <div class="mt-3 text-[10px] text-gray-400 font-semibold uppercase tracking-wider">30-Day Trend</div>
        <Sparkline data={orders_last_30} dateCol="metric_time" valueCol="late_delivery_rate" color="#9ca3af" height="25" />
      </div>
    </Grid>
  </div>
</div>

## Revenue & Volume Trends

<ECharts
  config={{
    title: { text: 'Revenue vs Order Volume', textStyle: { fontSize: 16, fontWeight: 'normal', fontFamily: 'sans-serif' }, left: '0%' },
    tooltip: { trigger: 'axis', axisPointer: { type: 'cross' } },
    legend: { bottom: 0 },
    grid: { left: 60, right: 60, top: 60, bottom: 40 },
    dataset: { source: orders_daily },
    xAxis: { 
      type: 'category', 
      boundaryGap: true,
      axisLabel: {
        formatter: function (value) {
          if (!value) return '';
          const d = new Date(value);
          return d.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
        }
      }
    },
    yAxis: [
      { 
        type: 'value', 
        name: 'Revenue ($)', 
        axisLabel: { formatter: '${value}' },
        splitLine: { show: true, lineStyle: { color: '#f3f4f6' } }
      },
      { 
        type: 'value', 
        name: 'Orders', 
        position: 'right',
        splitLine: { show: false }
      }
    ],
    series: [
      {
        type: 'bar',
        name: 'Total Orders',
        yAxisIndex: 1,
        barMaxWidth: 15,
        itemStyle: { color: '#94a3b8' },
        encode: { x: 'metric_time', y: 'total_orders', tooltip: ['total_orders'] }
      },
      {
        type: 'line',
        name: 'Total Revenue',
        smooth: true,
        yAxisIndex: 0,
        itemStyle: { color: '#1e3a8a' },
        lineStyle: { width: 3 },
        symbol: 'none',
        encode: { x: 'metric_time', y: 'total_revenue', tooltip: ['total_revenue'] }
      }
    ]
  }}
/>

## Delivered vs Total Orders Over Time

<LineChart
  data={orders_daily}
  x="metric_time"
  y={["total_orders", "delivered_orders"]}
  yFmt="num0"
  title="Orders Placed vs Successfully Delivered"
  chartAreaHeight=250
  echartsOptions={{ textStyle: { fontFamily: 'Playfair Display' } }}
/>

## Late Deliveries — Volume & Rate

<LineChart
  data={orders_daily}
  x="metric_time"
  y="late_deliveries"
  y2="late_delivery_rate"
  yFmt="num0"
  y2Fmt="pct1"
  title="Late Deliveries: Absolute Count (bars) vs Rate (line)"
  chartAreaHeight=250
  echartsOptions={{ textStyle: { fontFamily: 'Playfair Display' } }}
/>

## Average Order Value Over Time

<LineChart
  data={orders_daily}
  x="metric_time"
  y="average_order_value"
  yFmt="usd2"
  title="Average Order Value (AOV)"
  chartAreaHeight=250
  echartsOptions={{ textStyle: { fontFamily: 'Playfair Display' } }}
/>

## Average Fulfillment Days & Basket Size

<LineChart
  data={orders_daily}
  x="metric_time"
  y="average_fulfillment_days"
  yFmt="num1"
  title="Average Delivery Days"
  chartAreaHeight=250
  echartsOptions={{ textStyle: { fontFamily: 'Playfair Display' } }}
/>

<LineChart
  data={basket_size}
  x="metric_time"
  y="average_basket_size"
  yFmt="num2"
  title="Average Basket Size (Items per Order)"
  chartAreaHeight=250
  echartsOptions={{ textStyle: { fontFamily: 'Playfair Display' } }}
/>

## GMV & Items Sold

<BarChart
  data={items_daily}
  x="metric_time"
  y="total_gmv"
  yFmt="usd0"
  title="Daily Gross Merchandise Value"
  chartAreaHeight=250
  echartsOptions={{ textStyle: { fontFamily: 'Playfair Display' } }}
/>

## Order Status Breakdown

<DataTable
  data={orders_daily}
  groupBy="order_status"
  groupType="section"
>
  <Column id="metric_time" title="Date" />
  <Column id="total_orders" title="Orders" fmt="num0" />
  <Column id="delivered_orders" title="Delivered" fmt="num0" />
  <Column id="late_deliveries" title="Late" fmt="num0" />
  <Column id="total_revenue" title="Revenue" fmt="usd2" />
  <Column id="fulfillment_rate" title="Fulfillment Rate" fmt="pct1" />
  <Column id="late_delivery_rate" title="Late Rate" fmt="pct1" />
</DataTable>

---

**Navigation:** [Executive Overview](/) · [Customer Insights](/customers) · [Product & Sellers](/products) · [Data Quality](/data-quality)