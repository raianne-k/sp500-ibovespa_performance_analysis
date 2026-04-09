----------------------------------------------------------------
-- 05-build_monthly_price_model.sql
-- Aggregate daily price data to monthly grain and join all series.
-- Tables: analytics.monthly_sp500
--           analytics.monthly_ibov
--           analytics.monthly_usd_brl
--           analytics.monthly_cpi_us
--           analytics.monthly_cpi_br
--           analytics.monthly_market_model
--           analytics.monthly_market_model_clean
--           analytics.monthly_sp500_tr
--           analytics.monthly_ibds
--           analytics.monthly_market_model_tr
--           analytics.monthly_market_model_tr_clean
-- Run after 04.
----------------------------------------------------------------


-- -- Monthly averages (daily to monthly) ----------------------

CREATE TABLE analytics.monthly_sp500 AS
SELECT
    DATE_TRUNC('month', date)::DATE AS month_date,
    AVG(sp500)                      AS sp500_avg
FROM staging.stg_sp500
GROUP BY 1
ORDER BY 1;


CREATE TABLE analytics.monthly_ibov AS
SELECT
    DATE_TRUNC('month', date)::DATE AS month_date,
    AVG(ibov)                       AS ibov_avg
FROM staging.stg_ibov
GROUP BY 1
ORDER BY 1;


CREATE TABLE analytics.monthly_usd_brl AS
SELECT
    DATE_TRUNC('month', date)::DATE AS month_date,
    AVG(usd_brl)                    AS usd_brl_avg
FROM staging.stg_usd_brl
GROUP BY 1
ORDER BY 1;


-- -- CPI already monthly — just reformat ----------------------

CREATE TABLE analytics.monthly_cpi_us AS
SELECT
    DATE_TRUNC('month', date)::DATE AS month_date,
    cpi_us
FROM staging.stg_cpi_us
ORDER BY 1;


CREATE TABLE analytics.monthly_cpi_br AS
SELECT
    DATE_TRUNC('month', date)::DATE AS month_date,
    cpi_br
FROM staging.stg_cpi_br
ORDER BY 1;


-- -- Join series into model ------------------------------------

CREATE TABLE analytics.monthly_market_model AS
SELECT
    sp.month_date,
    sp.sp500_avg,
    ib.ibov_avg,
    fx.usd_brl_avg,
    br.cpi_br,
    us.cpi_us
FROM analytics.monthly_sp500    sp
LEFT JOIN analytics.monthly_ibov      ib ON sp.month_date = ib.month_date
LEFT JOIN analytics.monthly_usd_brl   fx ON sp.month_date = fx.month_date
LEFT JOIN analytics.monthly_cpi_br    br ON sp.month_date = br.month_date
LEFT JOIN analytics.monthly_cpi_us    us ON sp.month_date = us.month_date
ORDER BY sp.month_date;


-- -- Clean version: drop rows missing any key series ----------

CREATE TABLE analytics.monthly_market_model_clean AS
SELECT *
FROM analytics.monthly_market_model
WHERE sp500_avg   IS NOT NULL
  AND ibov_avg    IS NOT NULL
  AND usd_brl_avg IS NOT NULL
  AND cpi_br      IS NOT NULL;




-- -- SP500 TR: daily to monthly average ------------------------

CREATE TABLE analytics.monthly_sp500_tr AS
SELECT
    DATE_TRUNC('month', date)::DATE AS month_date,
    AVG(sp500_tr)                   AS sp500_tr_avg
FROM staging.stg_sp500_tr
GROUP BY 1
ORDER BY 1;


-- -- IBDS: monthly + reformat -----------------------------------

CREATE TABLE analytics.monthly_ibds AS
SELECT
    DATE_TRUNC('month', date)::DATE AS month_date,
    ibds
FROM staging.stg_ibds
ORDER BY 1;


-- -- Join TR series with existing FX and CPI --------------------
-- Reuses: analytics.monthly_usd_brl
--         analytics.monthly_cpi_br
--         analytics.monthly_cpi_us
-- (built in 05)

CREATE TABLE analytics.monthly_market_model_tr AS
SELECT
    sp.month_date,
    ib.ibds,
    sp.sp500_tr_avg,
    fx.usd_brl_avg,
    br.cpi_br,
    us.cpi_us
FROM analytics.monthly_sp500_tr    sp
LEFT JOIN analytics.monthly_ibds        ib ON sp.month_date = ib.month_date
LEFT JOIN analytics.monthly_usd_brl     fx ON sp.month_date = fx.month_date
LEFT JOIN analytics.monthly_cpi_br      br ON sp.month_date = br.month_date
LEFT JOIN analytics.monthly_cpi_us      us ON sp.month_date = us.month_date
ORDER BY sp.month_date;


-- -- Clean version: drop rows missing any key series ------------

CREATE TABLE analytics.monthly_market_model_tr_clean AS
SELECT *
FROM analytics.monthly_market_model_tr
WHERE ibds        IS NOT NULL
  AND sp500_tr_avg IS NOT NULL
  AND usd_brl_avg  IS NOT NULL
  AND cpi_br       IS NOT NULL;


-- ── Adding TR MODEL with FX INDEX ─────────────────────────

ALTER TABLE analytics.monthly_market_model_tr_clean
ADD COLUMN IF NOT EXISTS usd_brl_index NUMERIC;

UPDATE analytics.monthly_market_model_tr_clean t
SET usd_brl_index = p.usd_brl_index
FROM analytics.monthly_market_model_clean p
WHERE t.month_date = p.month_date;
