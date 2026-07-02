select 
    sum(total_orders) as total_orders,
    sum(total_revenue) as total_revenue,
    sum(total_orders * average_order_value) / sum(total_orders) as average_order_value,
    sum(total_orders * fulfillment_rate) / sum(total_orders) as fulfillment_rate,
    sum(total_orders * average_fulfillment_days) / sum(total_orders) as average_fulfillment_days
from snowflake.orders_daily
where metric_time >= '${inputs.range.start}' and metric_time <= '${inputs.range.end}'
