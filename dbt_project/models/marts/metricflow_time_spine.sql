{{
    config(
        materialized='table',
    )
}}

with days as (
    {{ dbt_date.get_base_dates(start_date="2016-01-01", end_date="2020-01-01") }}
)
select
    cast(date_day as date) as date_day
from days
