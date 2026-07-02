select * from snowflake.orders_daily
where metric_time >= '${inputs.range.start}' and metric_time <= '${inputs.range.end}'
