-- Verify that for each order, the sum of individual payment types
-- equals the total payment amount (excluding 'not_defined' types)
WITH payment_summary AS (
    SELECT
        order_id,
        SUM(CASE WHEN payment_type = 'boleto' THEN payment_value ELSE 0 END) AS boleto_amount,
        SUM(CASE WHEN payment_type = 'credit_card' THEN payment_value ELSE 0 END) AS credit_card_amount,
        SUM(CASE WHEN payment_type = 'voucher' THEN payment_value ELSE 0 END) AS voucher_amount,
        SUM(CASE WHEN payment_type = 'debit_card' THEN payment_value ELSE 0 END) AS debit_card_amount,
        SUM(payment_value) AS total_amount
    FROM {{ ref('stg_olist_order_payments') }}
    WHERE payment_type IN ('boleto', 'credit_card', 'voucher', 'debit_card')
    GROUP BY order_id
)
SELECT *
FROM payment_summary
WHERE (boleto_amount + credit_card_amount + voucher_amount + debit_card_amount) != total_amount
