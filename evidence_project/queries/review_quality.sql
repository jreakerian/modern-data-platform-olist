select * from snowflake.daily_review_quality
where metric_time >= '${inputs.range.start}' and metric_time <= '${inputs.range.end}'
