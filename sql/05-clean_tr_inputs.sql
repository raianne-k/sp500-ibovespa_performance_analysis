----------------------------------------------------------------
-- 05-clean_tr_inputs.sql
-- Transform raw TR tables into typed, clean staging tables 
-- for the TOTAL RETURN MODEL.
-- Tables: staging.stg_sp500_tr
--           staging.stg_ibds
-- These tables are parallel to the price model.
-- Do NOT modify or overwrite stg_sp500 or stg_ibov.
-- Run after 04 (price inputs already clean).
----------------------------------------------------------------


-- -- SP500 Total Return ---------------------------------------
-- Source  : Investing.com (SPXTR)
-- Issues  : MM/DD/YYYY date format, thousands commas in values,
--           UTF-8 BOM (handled at import), extra columns dropped.

CREATE TABLE staging.stg_sp500_tr AS
SELECT
    TO_DATE(date_text, 'MM/DD/YYYY')                          AS date,
    REPLACE(sp500_tr_text, ',', '')::NUMERIC(12,2)            AS sp500_tr
FROM staging.sp500_tr_raw
WHERE sp500_tr_text IS NOT NULL
  AND sp500_tr_text <> ''
ORDER BY 1;


-- -- IBDS — Ibovespa Total Return ----------------------------
-- Source  : B3 (IBDS monthly series)
-- Issues  : Separate month + year columns (no date column),
--           Brazilian numeric format: 1.084,01
--           remove dots (thousands sep), replace comma with dot.

CREATE TABLE staging.stg_ibds AS
SELECT
    -- Build a proper date from month + year: first day of month
    TO_DATE(year_text || '-' || LPAD(month_text, 2, '0') || '-01', 'YYYY-MM-DD') AS date,

    -- Convert Brazilian number format to standard decimal
    REPLACE(
        REPLACE(ibds_text, '.', ''),   
        ',', '.'                        
    )::NUMERIC(10,2) AS ibds

FROM staging.ibds_raw
WHERE ibds_text IS NOT NULL
  AND ibds_text <> ''
ORDER BY 1;
