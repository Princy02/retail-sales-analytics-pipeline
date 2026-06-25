-- Run these in Snowflake's web UI (Worksheets) one block at a time.

-- 1. Setup: warehouse, database, schema
CREATE WAREHOUSE IF NOT EXISTS RETAIL_WH WITH WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE;
CREATE DATABASE IF NOT EXISTS RETAIL_DB;
USE DATABASE RETAIL_DB;
CREATE SCHEMA IF NOT EXISTS RAW;
USE SCHEMA RAW;

-- 2. Raw table matching the ACTUAL Indian Store Data CSV columns (verified from file header)
CREATE OR REPLACE TABLE RAW.STORE_SALES (
    customer_id     VARCHAR,
    customer_name   VARCHAR,
    last_name       VARCHAR,
    date_of_birth   DATE,
    sales           FLOAT,
    year            INTEGER,
    outlet_type     VARCHAR,   -- Small / Medium / Large
    city_type       VARCHAR,   -- Tier 1 / Tier 2 / Village
    category        VARCHAR,   -- Category of Goods
    region          VARCHAR,
    country         VARCHAR,
    segment         VARCHAR,   -- Consumer / Corporate
    sales_date      DATE,
    order_id        VARCHAR,
    order_date      DATE,
    ship_date       DATE,
    ship_mode       VARCHAR,
    state           VARCHAR,
    postal_code     VARCHAR,
    product_id      VARCHAR,
    sub_category    VARCHAR,
    product_name    VARCHAR,
    quantity        INTEGER,
    discount        FLOAT,
    profit          FLOAT
);

-- 3. Create a file format for the CSV
CREATE OR REPLACE FILE FORMAT RAW.CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('NULL', 'null', '');

-- 4a. EASIEST PATH: Use Snowflake's web UI "Load Data" button
--     Snowsight -> Data -> Databases -> RETAIL_DB -> RAW -> STORE_SALES -> "Load Data"
--     Upload store_sales_data.csv directly, map columns, done. No staging/COPY INTO needed.

-- 4b. ALTERNATIVE: Stage + COPY INTO (if you prefer SQL-only / SnowSQL CLI)
-- CREATE OR REPLACE STAGE RAW.RETAIL_STAGE FILE_FORMAT = RAW.CSV_FORMAT;
-- (then use SnowSQL: PUT file://store_sales_data.csv @RAW.RETAIL_STAGE;)
-- COPY INTO RAW.STORE_SALES FROM @RAW.RETAIL_STAGE/store_sales_data.csv FILE_FORMAT = (FORMAT_NAME = RAW.CSV_FORMAT);

-- 5. Sanity check
SELECT COUNT(*) FROM RAW.STORE_SALES;
SELECT * FROM RAW.STORE_SALES LIMIT 10;
