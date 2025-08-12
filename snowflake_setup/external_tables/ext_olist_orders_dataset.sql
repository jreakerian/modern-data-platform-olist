-- Create an external table for the orders dataset
CREATE OR REPLACE EXTERNAL TABLE olist_orders_dataset (
    order_id VARCHAR AS (value:c1::VARCHAR),
    customer_id VARCHAR AS (value:c2::VARCHAR),
    order_status VARCHAR AS (value:c3::VARCHAR),
    order_purchase_timestamp TIMESTAMP_NTZ AS (TO_TIMESTAMP_NTZ(value:c4::VARCHAR)),
    order_approved_at TIMESTAMP_NTZ AS (TO_TIMESTAMP_NTZ(value:c5::VARCHAR)),
    order_delivered_carrier_date TIMESTAMP_NTZ AS (TO_TIMESTAMP_NTZ(value:c6::VARCHAR)),
    order_delivered_customer_date TIMESTAMP_NTZ AS (TO_TIMESTAMP_NTZ(value:c7::VARCHAR)),
    order_estimated_delivery_date TIMESTAMP_NTZ AS (TO_TIMESTAMP_NTZ(value:c8::VARCHAR))
)
WITH LOCATION = @OLIST_LAKEHOUSE.RAW_BRONZE.OLIST_BRONZE_STAGE/
PATTERN = '.*olist_orders_dataset\\.csv$'
AUTO_REFRESH = FALSE
FILE_FORMAT = (FORMAT_NAME = 'olist_csv_format');

LIST @OLIST_LAKEHOUSE.RAW_BRONZE.OLIST_BRONZE_STAGE;

-- Create an external table for the customers dataset
CREATE OR REPLACE EXTERNAL TABLE olist_customers_dataset (
    customer_id VARCHAR AS (value:c1::VARCHAR),
    customer_unique_id VARCHAR AS (value:c2::VARCHAR),
    customer_zip_code_prefix VARCHAR AS (value:c3::VARCHAR),
    customer_city VARCHAR AS (value:c4::VARCHAR),
    customer_state VARCHAR AS (value:c5::VARCHAR)
)
WITH LOCATION = @olist_bronze_stage/
PATTERN = '.*olist_customers_dataset\\.csv$'
FILE_FORMAT = (FORMAT_NAME = 'olist_csv_format')
AUTO_REFRESH = FALSE;

CREATE OR REPLACE EXTERNAL TABLE olist_geolocation_dataset (
        geolocation_zip_code_prefix VARCHAR AS (value:c1::VARCHAR),
        geolocation_lat             NUMBER(10, 8) AS (value:c2::NUMBER(10, 8)),
        geolocation_lng             NUMBER(11, 8) AS (value:c3::NUMBER(11, 8)),
        geolocation_city            VARCHAR AS (value:c4::VARCHAR),
        geolocation_state           VARCHAR AS (value:c5::VARCHAR)
)
WITH LOCATION = @olist_bronze_stage/
PATTERN = '.*olist_geolocation_dataset\\.csv$'
FILE_FORMAT = (FORMAT_NAME = 'olist_csv_format')
AUTO_REFRESH = FALSE;

CREATE OR REPLACE EXTERNAL TABLE olist_order_items_dataset(
    order_id            VARCHAR AS (value:c1::VARCHAR),
    order_item_id       NUMBER AS (value:c2::NUMBER),
    product_id          VARCHAR AS (value:c3::VARCHAR),
    seller_id           VARCHAR AS (value:c4::VARCHAR),
    shipping_limit_date TIMESTAMP_NTZ AS (TO_TIMESTAMP_NTZ(value:c5::VARCHAR)),
    price               NUMBER(10, 2) AS (value:c6::NUMBER(10, 2)),
    freight_value       NUMBER(10, 2) AS (value:c7::NUMBER(10, 2))
)
WITH LOCATION = @olist_bronze_stage/
PATTERN = '.*olist_order_items_dataset\\.csv$'
FILE_FORMAT = (FORMAT_NAME = 'olist_csv_format')
AUTO_REFRESH = FALSE;

CREATE OR REPLACE EXTERNAL TABLE olist_order_payments_dataset (
    order_id             VARCHAR AS (value:c1::VARCHAR),
    payment_sequential   NUMBER AS (value:c2::NUMBER),
    payment_type         VARCHAR AS (value:c3::VARCHAR),
    payment_installments NUMBER AS (value:c4::NUMBER),
    payment_value        NUMBER(10, 2) AS (value:c5::NUMBER(10, 2))
)
WITH LOCATION = @olist_bronze_stage/
PATTERN = '.*olist_order_payments_dataset\\.csv$'
FILE_FORMAT = (FORMAT_NAME = 'olist_csv_format')
AUTO_REFRESH = FALSE;

CREATE OR REPLACE EXTERNAL TABLE olist_order_reviews_dataset(
    review_id               VARCHAR AS (value:c1::VARCHAR),
    order_id                VARCHAR AS (value:c2::VARCHAR),
    review_score            NUMBER AS (value:c3::NUMBER),
    review_comment_title    VARCHAR AS (value:c4::VARCHAR),
    review_comment_message  VARCHAR AS (value:c5::VARCHAR),
    review_creation_date    TIMESTAMP_NTZ AS (TO_TIMESTAMP_NTZ(value:c6::VARCHAR)),
    review_answer_timestamp TIMESTAMP_NTZ AS (TO_TIMESTAMP_NTZ(value:c7::VARCHAR))
)
WITH LOCATION = @olist_bronze_stage/
PATTERN = '.*olist_order_reviews_dataset\\.csv$'
FILE_FORMAT = (FORMAT_NAME = 'olist_csv_format')
AUTO_REFRESH = FALSE;


CREATE OR REPLACE EXTERNAL TABLE olist_products_dataset (
    product_id                 VARCHAR AS (value:c1::VARCHAR),
    product_category_name      VARCHAR AS (value:c2::VARCHAR),
    product_name_lenght        NUMBER AS (value:c3::NUMBER),
    product_description_lenght NUMBER AS (value:c4::NUMBER),
    product_photos_qty         NUMBER AS (value:c5::NUMBER),
    product_weight_g           NUMBER AS (value:c6::NUMBER),
    product_length_cm          NUMBER AS (value:c7::NUMBER),
    product_height_cm          NUMBER AS (value:c8::NUMBER),
    product_width_cm           NUMBER AS (value:c9::NUMBER)
)
WITH LOCATION = @olist_bronze_stage/
PATTERN = '.*olist_products_dataset\\.csv$'
FILE_FORMAT = (FORMAT_NAME = 'olist_csv_format')
AUTO_REFRESH = FALSE;

CREATE OR REPLACE EXTERNAL TABLE olist_sellers_dataset(
    seller_id              VARCHAR AS (value:c1::VARCHAR),
    seller_zip_code_prefix VARCHAR AS (value:c2::VARCHAR),
    seller_city            VARCHAR AS (value:c3::VARCHAR),
    seller_state           VARCHAR AS (value:c4::VARCHAR)
)
WITH LOCATION = @olist_bronze_stage/
PATTERN = '.*olist_sellers_dataset\\.csv$'
FILE_FORMAT = (FORMAT_NAME = 'olist_csv_format')
AUTO_REFRESH = FALSE;

CREATE OR REPLACE EXTERNAL TABLE product_category_name_translation(
    product_category_name         VARCHAR AS (value:c1::VARCHAR),
    product_category_name_english VARCHAR AS (value:c2::VARCHAR)
)
WITH LOCATION = @olist_bronze_stage/
PATTERN = '.*product_category_name_translation\\.csv$'
FILE_FORMAT = (FORMAT_NAME = 'olist_csv_format')
AUTO_REFRESH = FALSE;