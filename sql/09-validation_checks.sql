----------------------------------------------------------------
-- 9-validation_checks.sql
-- Run after any major build step to confirm data integrity.
----------------------------------------------------------------


---------------------------------------------------------------
-- A: Row counts
---------------------------------------------------------------

--   stg_sp500       ~1800 rows  (trading days 2019–2026)
--   stg_ibov        ~1700 rows  (trading days, all years)
--   stg_usd_brl     ~2500 rows  (BCB PTAX daily)
--   stg_cpi_us      ~86 rows    (monthly)
--   stg_cpi_br      ~86 rows    (monthly)
--   stg_sp500_tr    ~1800 rows  (trading days)
--   stg_ibds        ~88 rows    (monthly)

SELECT 'stg_sp500'    AS tbl, COUNT(*) FROM staging.stg_sp500    UNION ALL
SELECT 'stg_ibov',            COUNT(*) FROM staging.stg_ibov      UNION ALL
SELECT 'stg_usd_brl',         COUNT(*) FROM staging.stg_usd_brl   UNION ALL
SELECT 'stg_cpi_us',          COUNT(*) FROM staging.stg_cpi_us    UNION ALL
SELECT 'stg_cpi_br',          COUNT(*) FROM staging.stg_cpi_br    UNION ALL
SELECT 'stg_sp500_tr',        COUNT(*) FROM staging.stg_sp500_tr  UNION ALL
SELECT 'stg_ibds',            COUNT(*) FROM staging.stg_ibds
ORDER BY tbl;


---------------------------------------------------------------
-- B: Date ranges
---------------------------------------------------------------

SELECT 'stg_sp500'   AS tbl, MIN(date), MAX(date) FROM staging.stg_sp500    UNION ALL
SELECT 'stg_ibov',           MIN(date), MAX(date) FROM staging.stg_ibov      UNION ALL
SELECT 'stg_usd_brl',        MIN(date), MAX(date) FROM staging.stg_usd_brl   UNION ALL
SELECT 'stg_cpi_us',         MIN(date), MAX(date) FROM staging.stg_cpi_us    UNION ALL
SELECT 'stg_cpi_br',         MIN(date), MAX(date) FROM staging.stg_cpi_br    UNION ALL
SELECT 'stg_sp500_tr',       MIN(date), MAX(date) FROM staging.stg_sp500_tr  UNION ALL
SELECT 'stg_ibds',           MIN(date), MAX(date) FROM staging.stg_ibds
ORDER BY tbl;


---------------------------------------------------------------
-- C: Null checks (monthly models)
---------------------------------------------------------------

-- Price model
SELECT 'price_model_nulls' AS check,
       COUNT(*) AS rows_with_nulls
FROM analytics.monthly_market_model_clean
WHERE sp500_avg IS NULL
   OR ibov_avg IS NULL
   OR usd_brl_avg IS NULL
   OR cpi_br IS NULL;

-- TR model
SELECT 'tr_model_nulls' AS check,
       COUNT(*) AS rows_with_nulls
FROM analytics.monthly_market_model_tr_clean
WHERE sp500_tr_avg IS NULL
   OR ibds IS NULL
   OR usd_brl_avg IS NULL
   OR cpi_br IS NULL;


---------------------------------------------------------------
-- D: Duplicate date check
---------------------------------------------------------------

SELECT 'stg_sp500 dupes'   , COUNT(*) - COUNT(DISTINCT date) FROM staging.stg_sp500    UNION ALL
SELECT 'stg_ibov dupes'    , COUNT(*) - COUNT(DISTINCT date) FROM staging.stg_ibov      UNION ALL
SELECT 'stg_sp500_tr dupes', COUNT(*) - COUNT(DISTINCT date) FROM staging.stg_sp500_tr  UNION ALL
SELECT 'stg_ibds dupes'    , COUNT(*) - COUNT(DISTINCT date) FROM staging.stg_ibds;


---------------------------------------------------------------
-- E: First and last rows (price model)
---------------------------------------------------------------

SELECT 'first' AS row, * FROM analytics.monthly_market_model_clean ORDER BY month_date ASC  LIMIT 1
UNION ALL
SELECT 'last',         * FROM analytics.monthly_market_model_clean ORDER BY month_date DESC LIMIT 1;


---------------------------------------------------------------
-- F: First and last rows (TR model)
---------------------------------------------------------------

SELECT 'first' AS row, * FROM analytics.monthly_market_model_tr_clean ORDER BY month_date ASC  LIMIT 1
UNION ALL
SELECT 'last',         * FROM analytics.monthly_market_model_tr_clean ORDER BY month_date DESC LIMIT 1;


---------------------------------------------------------------
-- G: Index sanity. First row = 100
---------------------------------------------------------------

SELECT
    month_date,
    ibov_index,
    sp500_brl_index,
    cpi_br_index,
    ibov_real_index,
    sp500_brl_real_index
FROM analytics.monthly_market_model_clean
ORDER BY month_date
LIMIT 1;

-- Total Return:

SELECT
    month_date,
    ibds_index,
    sp500_tr_brl_index,
    cpi_br_index,
    ibds_real_index,
    sp500_tr_brl_real_index
FROM analytics.monthly_market_model_tr_clean
ORDER BY month_date
LIMIT 1;


---------------------------------------------------------------
-- H: Value range checks
---------------------------------------------------------------

SELECT
    MIN(usd_brl_avg) AS fx_min,
    MAX(usd_brl_avg) AS fx_max,   -- 3.7 to 6.5
    MIN(cpi_br)      AS cpi_min,
    MAX(cpi_br)      AS cpi_max   -- 5.1 to 7.5
FROM analytics.monthly_market_model_tr_clean;
