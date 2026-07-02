select * from snowflake.daily_basket_size
where metric_time >= '${inputs.range.start}' and metric_time <= '${inputs.range.end}'
