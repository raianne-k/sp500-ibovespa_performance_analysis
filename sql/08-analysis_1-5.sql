----------------------------------------------------------------
-- 10-analysis_1-5.sql
-- 5 questions as specified. Run after 09. All queries are read-only.
-- Goal: "For a Brazilian investor, which investment 
-- Ibovespa or S&P 500 — delivered better inflation-adjusted 
-- returns in BRL post-pandemic?"
----------------------------------------------------------------


----------------------------------------------------------------
-- 1: Which investment delivered better real BRL returns for a Brazilian investor?
-- final row of TR model 
----------------------------------------------------------------

WITH last_row AS (
    SELECT *
    FROM analytics.monthly_market_model_tr_clean
    ORDER BY month_date DESC
    LIMIT 1
)
SELECT
    ROUND(ibds_real_index - 100, 2) AS ibds_real_return_pct,
    ROUND(sp500_tr_brl_real_index - 100, 2) AS sp500_tr_real_return_pct
FROM last_row;


----------------------------------------------------------------
-- 2: How much does the answer change when dividends included?
-- final row of price model
-- final row of TR model
----------------------------------------------------------------

WITH price_last AS (
    SELECT *
    FROM analytics.monthly_market_model_clean
    ORDER BY month_date DESC
    LIMIT 1
),
tr_last AS (
    SELECT *
    FROM analytics.monthly_market_model_tr_clean
    ORDER BY month_date DESC
    LIMIT 1
)
SELECT
    'price_model' AS model,
    ROUND(ibov_real_index - 100, 2) AS brazil_real_return_pct,
    ROUND(sp500_brl_real_index - 100, 2) AS sp500_real_return_pct
FROM price_last

UNION ALL

SELECT
    'total_return_model',
    ROUND(ibds_real_index - 100, 2),
    ROUND(sp500_tr_brl_real_index - 100, 2)
FROM tr_last;


----------------------------------------------------------------
-- 3: Was the difference driven by market returns or FX?
-- CTE with Decomposition of S&P 500 BRL return into market + FX components.
-- sp500_tr_usd_index | sp500_tr_brl_index | usd_brl_index
----------------------------------------------------------------

WITH bookends AS (
    SELECT
        FIRST_VALUE(sp500_tr_avg) OVER (ORDER BY month_date)
            AS sp_start,
        LAST_VALUE(sp500_tr_avg)  OVER (ORDER BY month_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
            AS sp_end,
        FIRST_VALUE(usd_brl_avg) OVER (ORDER BY month_date)
            AS fx_start,
        LAST_VALUE(usd_brl_avg)  OVER (ORDER BY month_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
            AS fx_end
    FROM analytics.monthly_market_model_tr_clean
    LIMIT 1
)
SELECT
    ROUND((sp_end / sp_start - 1) * 100, 2)              AS market_return_usd_pct,
    ROUND((fx_end / fx_start - 1) * 100, 2)              AS fx_depreciation_pct,
    ROUND((sp_end * fx_end) / (sp_start * fx_start) * 100 - 100, 2)
                                                          AS total_brl_return_pct
FROM bookends;


-- -------------------------------------------------------------
-- 4: How did performance vary over time?
-- 4a: CTE for yearly real returns, both assets (TR model)
-- -------------------------------------------------------------

WITH yearly AS (
    SELECT
        EXTRACT(YEAR FROM month_date)::INT AS yr,
        FIRST_VALUE(ibds_index)              OVER w AS ib_open,
        LAST_VALUE(ibds_index)               OVER w AS ib_close,
        FIRST_VALUE(sp500_tr_brl_index)      OVER w AS sp_open,
        LAST_VALUE(sp500_tr_brl_index)       OVER w AS sp_close,
        FIRST_VALUE(cpi_br_index)            OVER w AS cpi_open,
        LAST_VALUE(cpi_br_index)             OVER w AS cpi_close
    FROM analytics.monthly_market_model_tr_clean
    WINDOW w AS (
        PARTITION BY EXTRACT(YEAR FROM month_date)
        ORDER BY month_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    )
)
SELECT DISTINCT
    yr,
    ROUND((sp_close/sp_open) / (cpi_close/cpi_open) * 100 - 100, 2) AS sp500_tr_real_pct,
    ROUND((ib_close/ib_open) / (cpi_close/cpi_open) * 100 - 100, 2) AS ibds_real_pct
FROM yearly
ORDER BY yr;


-- -------------------------------------------------------------
-- 4b: Performance by phases
-- Phase: pre-pandemic / shock / recovery / post-pandemic
-- -------------------------------------------------------------

WITH phase_ranges AS (
    SELECT '1_pre_pandemic' AS phase, DATE '2019-01-01' AS start_date, DATE '2020-02-01' AS end_date
    UNION ALL
    SELECT '2_shock',         DATE '2020-02-01', DATE '2020-11-01'
    UNION ALL
    SELECT '3_recovery',      DATE '2020-11-01', DATE '2022-01-01'
    UNION ALL
    SELECT '4_post_pandemic', DATE '2022-01-01', DATE '2026-03-01'
),
phases AS (
    SELECT
        m.month_date,
        m.ibds_index,
        m.sp500_tr_brl_index,
        m.cpi_br_index,
        p.phase
    FROM analytics.monthly_market_model_tr_clean m
    JOIN phase_ranges p
      ON m.month_date >= p.start_date
     AND m.month_date <  p.end_date
),
bookends AS (
    SELECT
        phase,
        month_date,
        FIRST_VALUE(sp500_tr_brl_index) OVER w AS sp_open,
        LAST_VALUE(sp500_tr_brl_index)  OVER w AS sp_close,
        FIRST_VALUE(ibds_index)         OVER w AS ib_open,
        LAST_VALUE(ibds_index)          OVER w AS ib_close,
        FIRST_VALUE(cpi_br_index)       OVER w AS cpi_open,
        LAST_VALUE(cpi_br_index)        OVER w AS cpi_close
    FROM phases
    WINDOW w AS (
        PARTITION BY phase
        ORDER BY month_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    )
)
SELECT DISTINCT
    phase,
    ROUND((sp_close / sp_open) / (cpi_close / cpi_open) * 100 - 100, 2) AS sp500_tr_real_pct,
    ROUND((ib_close / ib_open) / (cpi_close / cpi_open) * 100 - 100, 2) AS ibds_real_pct
FROM bookends
ORDER BY phase;


-- --------------------------------------------------------------
-- 5: How do taxes, FX costs, and investment routes affect the relative outcome?
-- Direct US brokerage (FX spread, IOF, capital gains) / Global EFT via local broker  (USD exposure, Annual fund fee (TER), tracking
-- BDR route(annual drag, no direct FX conversion *approximate*) / Domestic (IBDS, tax only)
-- Actual treatment varies: this is indicative and based on static data.
-- --------------------------------------------------------------

WITH base AS (
    SELECT
        MAX(sp500_tr_brl_real_index) - 100 AS sp500_return,
        MAX(ibds_real_index) - 100 AS ibds_return
    FROM analytics.monthly_market_model_tr_clean
),

params AS (
    SELECT
        -- Low friction
        0.15  AS tax_low,
        0.01  AS fx_low,
        0.003 AS drag_low,

        -- High friction
        0.225 AS tax_high,
        0.03  AS fx_high,
        0.007 AS drag_high,

        -- Shared
        0.0076 AS iof,
        7 AS years
)

SELECT

    -- Base (no friction)
    ROUND(sp500_return, 2) AS sp500_base,
    ROUND(ibds_return, 2)  AS ibds_base,

    --------------------------------------------------
    -- 1. Direct US brokerage (FX + IOF + tax)
    --------------------------------------------------

    ROUND(
        sp500_return
        * (1 - tax_low)
        * (1 - iof)
        * (1 - fx_low),
        2
    ) AS us_broker_low,

    ROUND(
        sp500_return
        * (1 - tax_high)
        * (1 - iof)
        * (1 - fx_high),
        2
    ) AS us_broker_high,

    --------------------------------------------------
    -- 2. Global ETF via local broker (annual drag)
    --------------------------------------------------

 ROUND(
    (
        (1 + sp500_return/100)
        * POWER((1 - drag_low), years)
        - 1
    ) * 100
    * (1 - tax_low),
    2
) AS local_etf_low,

ROUND(
    (
        (1 + sp500_return/100)
        * POWER((1 - drag_high), years)
        - 1
    ) * 100
    * (1 - tax_high),
    2
) AS local_etf_high,

    --------------------------------------------------
    -- 3. Domestic IBDS (tax only)
    --------------------------------------------------

    ROUND(ibds_return * (1 - tax_low), 2)  AS ibds_low,
    ROUND(ibds_return * (1 - tax_high), 2) AS ibds_high

FROM base, params;
