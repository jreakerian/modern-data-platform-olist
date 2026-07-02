{{ config(materialized='ephemeral') }}

{%- set payment_methods = ['boleto', 'credit_card', 'voucher', 'debit_card'] -%}

with payments as (
    select * from {{ ref('stg_olist_order_payments') }}
),

pivoted as (
    select
         order_id,
         {%for method in payment_methods-%}
         SUM(CASE WHEN payment_type = '{{method}}' THEN payment_value ELSE 0 END) AS {{method}}_amount{%if not loop.last%},{%endif%}
         {%endfor-%},
         SUM(payment_value) AS total_amount
    from payments
    WHERE payment_type IN ('boleto','credit_card','voucher','debit_card')
    group by 1
)
select * from pivoted
