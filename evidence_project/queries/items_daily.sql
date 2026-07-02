select * from snowflake.items_daily
where metric_time >= '${inputs.range.start}' and metric_time <= '${inputs.range.end}'
