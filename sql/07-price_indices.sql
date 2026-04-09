----------------------------------------------------------------
-- 06-build_price_indices.sql
-- Build derived index columns on the price model.
-- Everything rebased to 100 at first observation.
-- Real indices deflated using Brazilian CPI (IPCA).
-- Columns added to analytics.monthly_market_model_clean
-- Run after 05.
----------------------------------------------------------------


-- -- Add columns --------------------------------------

ALTER TABLE analytics.monthly_market_model_clean
    ADD COLUMN sp500_brl            NUMERIC(14,2),
    ADD COLUMN sp500_usd_index      NUMERIC(10,4),
    ADD COLUMN sp500_brl_index      NUMERIC(10,4),
    ADD COLUMN ibov_index           NUMERIC(10,4),
    ADD COLUMN usd_brl_index        NUMERIC(10,4),
    ADD COLUMN cpi_br_index         NUMERIC(10,4),
    ADD COLUMN ibov_real_index      NUMERIC(10,4),
    ADD COLUMN sp500_brl_real_index NUMERIC(10,4);


-- -- S&P 500 converted to BRL -------------------------

UPDATE analytics.monthly_market_model_clean
SET sp500_brl = ROUND(sp500_avg * usd_brl_avg, 2);


-- -- Base indices (rebase all series to 100) ----------

UPDATE analytics.monthly_market_model_clean m
SET
    sp500_usd_index = ROUND((m.sp500_avg  / b.sp500_base)  * 100, 4),
    sp500_brl_index = ROUND((m.sp500_brl  / b.sp_brl_base) * 100, 4),
    ibov_index      = ROUND((m.ibov_avg   / b.ibov_base)   * 100, 4),
    usd_brl_index   = ROUND((m.usd_brl_avg / b.fx_base)    * 100, 4),
    cpi_br_index    = ROUND((m.cpi_br     / b.cpi_br_base) * 100, 4)
FROM (
    SELECT
        sp500_avg   AS sp500_base,
        sp500_brl   AS sp_brl_base,
        ibov_avg    AS ibov_base,
        usd_brl_avg AS fx_base,
        cpi_br      AS cpi_br_base
    FROM analytics.monthly_market_model_clean
    ORDER BY month_date
    LIMIT 1
) b;


-- -- Real indices (deflate by Brazilian CPI) ----------
-- real_index = (nominal_index / cpi_br_index) * 100
-- Interpretation: purchasing-power-adjusted return in BRL.

UPDATE analytics.monthly_market_model_clean
SET
    ibov_real_index      = ROUND((ibov_index      / cpi_br_index) * 100, 4),
    sp500_brl_real_index = ROUND((sp500_brl_index / cpi_br_index) * 100, 4);


-----------------------


-- -- Add columns (TR model) ----------------------------------------------

ALTER TABLE analytics.monthly_market_model_tr_clean
    ADD COLUMN sp500_tr_brl              NUMERIC(14,2),
    ADD COLUMN sp500_tr_usd_index        NUMERIC(10,4),
    ADD COLUMN sp500_tr_brl_index        NUMERIC(10,4),
    ADD COLUMN ibds_index                NUMERIC(10,4),
    ADD COLUMN usd_brl_index             NUMERIC(10,4),
    ADD COLUMN cpi_br_index              NUMERIC(10,4),
    ADD COLUMN ibds_real_index           NUMERIC(10,4),
    ADD COLUMN sp500_tr_brl_real_index   NUMERIC(10,4);


-- -- S&P 500 TR converted to BRL -----------------------------

UPDATE analytics.monthly_market_model_tr_clean
SET sp500_tr_brl = ROUND(sp500_tr_avg * usd_brl_avg, 2);


-- -- Base indices (rebase all series to 100) -----------------

UPDATE analytics.monthly_market_model_tr_clean m
SET
    sp500_tr_usd_index = ROUND((m.sp500_tr_avg / b.sp_tr_base)    * 100, 4),
    sp500_tr_brl_index = ROUND((m.sp500_tr_brl / b.sp_tr_brl_base)* 100, 4),
    ibds_index         = ROUND((m.ibds         / b.ibds_base)      * 100, 4),
    usd_brl_index      = ROUND((m.usd_brl_avg  / b.fx_base)        * 100, 4),
    cpi_br_index       = ROUND((m.cpi_br       / b.cpi_br_base)    * 100, 4)
FROM (
    SELECT
        sp500_tr_avg AS sp_tr_base,
        sp500_tr_brl AS sp_tr_brl_base,
        ibds         AS ibds_base,
        usd_brl_avg  AS fx_base,
        cpi_br       AS cpi_br_base
    FROM analytics.monthly_market_model_tr_clean
    ORDER BY month_date
    LIMIT 1
) b;


-- -- Real indices (deflate by Brazilian CPI) -----------------

UPDATE analytics.monthly_market_model_tr_clean
SET
    ibds_real_index          = ROUND((ibds_index          / cpi_br_index) * 100, 4),
    sp500_tr_brl_real_index  = ROUND((sp500_tr_brl_index  / cpi_br_index) * 100, 4);
