{{
    config(
        materialized='table',
    )
}}

WITH DAYS AS (
    {{ dbt_date.get_base_dates(start_date="2016-01-01", end_date="2020-01-01") }}
)

SELECT CAST(DATE_DAY AS DATE) AS DATE_DAY
FROM DAYS
