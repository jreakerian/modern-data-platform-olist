{{ config(materialized='ephemeral') }}

{%- set payment_methods = ['boleto', 'credit_card', 'voucher', 'debit_card'] -%}

with PAYMENTS AS (
    SELECT * FROM {{ ref('stg_olist_order_payments') }}
),

PIVOTED AS (
    SELECT
        ORDER_ID,
        {% for method in payment_methods -%}
            SUM(CASE WHEN PAYMENT_TYPE = '{{ method }}' THEN PAYMENT_VALUE ELSE 0 END)

                AS {{ method }}_amount{% if not loop.last %}
                ,
            {% endif %}
        {% endfor -%},
        SUM(PAYMENT_VALUE) AS TOTAL_AMOUNT
    FROM PAYMENTS
    WHERE PAYMENT_TYPE IN ('boleto', 'credit_card', 'voucher', 'debit_card')
    GROUP BY 1
)

SELECT * FROM PIVOTED
