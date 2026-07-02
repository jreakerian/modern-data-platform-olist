-- Verify that for each order, the sum of individual payment types
-- equals the total payment amount (excluding 'not_defined' types)
WITH PAYMENT_SUMMARY AS (
    SELECT
        ORDER_ID,
        SUM(CASE WHEN PAYMENT_TYPE = 'boleto' THEN PAYMENT_VALUE ELSE 0 END) AS BOLETO_AMOUNT,
        SUM(CASE WHEN PAYMENT_TYPE = 'credit_card' THEN PAYMENT_VALUE ELSE 0 END) AS CREDIT_CARD_AMOUNT,
        SUM(CASE WHEN PAYMENT_TYPE = 'voucher' THEN PAYMENT_VALUE ELSE 0 END) AS VOUCHER_AMOUNT,
        SUM(CASE WHEN PAYMENT_TYPE = 'debit_card' THEN PAYMENT_VALUE ELSE 0 END) AS DEBIT_CARD_AMOUNT,
        SUM(PAYMENT_VALUE) AS TOTAL_AMOUNT
    FROM {{ ref('stg_olist_order_payments') }}
    WHERE PAYMENT_TYPE IN ('boleto', 'credit_card', 'voucher', 'debit_card')
    GROUP BY ORDER_ID
)

SELECT *
FROM PAYMENT_SUMMARY
WHERE (BOLETO_AMOUNT + CREDIT_CARD_AMOUNT + VOUCHER_AMOUNT + DEBIT_CARD_AMOUNT) != TOTAL_AMOUNT
