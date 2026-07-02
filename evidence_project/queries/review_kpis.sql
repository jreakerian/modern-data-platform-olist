select
    sum(total_reviews)                                               as total_reviews,
    sum(negative_reviews)                                            as negative_reviews,
    sum(total_reviews * negative_review_rate) / sum(total_reviews)   as negative_review_rate,
    sum(total_reviews * average_review_score) / sum(total_reviews)   as average_review_score
from snowflake.daily_review_quality
where metric_time >= '${inputs.range.start}' and metric_time <= '${inputs.range.end}'
