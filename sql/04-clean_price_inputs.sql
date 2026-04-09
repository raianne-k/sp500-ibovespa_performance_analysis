----------------------------------------------------------------
-- 04-clean_price_inputs.sql
-- Transform raw tables into typed, clean staging tables PRICE MODEL.
-- Tables: staging.stg_sp500
--         staging.stg_ibov
--         staging.stg_usd_brl
--         staging.stg_cpi_us
--         staging.stg_cpi_br
-- Run after all CSVs imported into *_raw tables.
----------------------------------------------------------------


-- -- SP500 (price) --------------------------------------------

CREATE TABLE staging.stg_sp500 AS
SELECT
    observation_date::DATE  AS date,
    sp500::NUMERIC(10,2)    AS sp500
FROM staging.sp500_raw
WHERE sp500 IS NOT NULL
  AND sp500 <> '';


-- -- IBOVESPA (price) -----------------------------------------
-- Reshape each wide to long format then union all years.

CREATE TABLE staging.stg_ibov AS

-- 2019
SELECT date_text::DATE AS date,
       REPLACE(ibov_text, ',', '')::NUMERIC(12,2) AS ibov
FROM staging.ibov_2019_raw
WHERE ibov_text IS NOT NULL AND ibov_text <> ''

UNION ALL

-- 2020
SELECT date_text::DATE,
       REPLACE(ibov_text, ',', '')::NUMERIC(12,2)
FROM staging.ibov_2020_raw
WHERE ibov_text IS NOT NULL AND ibov_text <> ''

UNION ALL

-- 2021
SELECT date_text::DATE,
       REPLACE(ibov_text, ',', '')::NUMERIC(12,2)
FROM staging.ibov_2021_raw
WHERE ibov_text IS NOT NULL AND ibov_text <> ''

UNION ALL

-- 2022
SELECT date_text::DATE,
       REPLACE(ibov_text, ',', '')::NUMERIC(12,2)
FROM staging.ibov_2022_raw
WHERE ibov_text IS NOT NULL AND ibov_text <> ''

UNION ALL

-- 2023
SELECT date_text::DATE,
       REPLACE(ibov_text, ',', '')::NUMERIC(12,2)
FROM staging.ibov_2023_raw
WHERE ibov_text IS NOT NULL AND ibov_text <> ''

UNION ALL

-- 2024
SELECT date_text::DATE,
       REPLACE(ibov_text, ',', '')::NUMERIC(12,2)
FROM staging.ibov_2024_raw
WHERE ibov_text IS NOT NULL AND ibov_text <> ''

UNION ALL

-- 2025
SELECT date_text::DATE,
       REPLACE(ibov_text, ',', '')::NUMERIC(12,2)
FROM staging.ibov_2025_raw
WHERE ibov_text IS NOT NULL AND ibov_text <> ''

UNION ALL

-- 2026
SELECT date_text::DATE,
       REPLACE(ibov_text, ',', '')::NUMERIC(12,2)
FROM staging.ibov_2026_raw
WHERE ibov_text IS NOT NULL AND ibov_text <> '';


-- -- USD/BRL ----------------------------------------------------

CREATE TABLE staging.stg_usd_brl AS
SELECT
    date_text::DATE             AS date,
    usd_brl_text::NUMERIC(8,4)  AS usd_brl
FROM staging.usd_brl_raw
WHERE usd_brl_text IS NOT NULL
  AND usd_brl_text <> '';


-- -- CPI US -----------------------------------------------------

CREATE TABLE staging.stg_cpi_us AS
SELECT
    observation_date::DATE      AS date,
    cpi_us_text::NUMERIC(8,3)   AS cpi_us
FROM staging.cpi_us_raw
WHERE cpi_us_text IS NOT NULL
  AND cpi_us_text <> '';


-- -- CPI BR -----------------------------------------------------
-- Already pivoted wide to long in Sheets before import.

CREATE TABLE staging.stg_cpi_br AS
SELECT
    date_text::DATE             AS date,
    cpi_br_text::NUMERIC(10,2)  AS cpi_br
FROM staging.cpi_br_raw
WHERE cpi_br_text IS NOT NULL
  AND cpi_br_text <> '';
