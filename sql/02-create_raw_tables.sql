----------------------------------------------------------------
-- 02-create_raw_tables.sql
-- Create raw landing tables exactly matching CSV structure
-- No transformation here:text only.
-- Run after 01. Before any COPY / DB import.
----------------------------------------------------------------


-- -- PRICE MODEL ----------------------------------------------

CREATE TABLE staging.sp500_raw (
    observation_date TEXT,
    sp500            TEXT
);

-- -- PRICE MODEL INPUTS ---------------------------------------

-- Ibovespa (IBOV) – Price Index
-- Source: B3 (Brasil Bolsa Balcão)
-- Format: one file per year, wide calendar (day × month)
-- Note: reshaped to long format during cleaning
CREATE TABLE staging.ibov_2019_raw (date_text TEXT, ibov_text TEXT);
CREATE TABLE staging.ibov_2020_raw (date_text TEXT, ibov_text TEXT);
CREATE TABLE staging.ibov_2021_raw (date_text TEXT, ibov_text TEXT);
CREATE TABLE staging.ibov_2022_raw (date_text TEXT, ibov_text TEXT);
CREATE TABLE staging.ibov_2023_raw (date_text TEXT, ibov_text TEXT);
CREATE TABLE staging.ibov_2024_raw (date_text TEXT, ibov_text TEXT);
CREATE TABLE staging.ibov_2025_raw (date_text TEXT, ibov_text TEXT);
CREATE TABLE staging.ibov_2026_raw (date_text TEXT, ibov_text TEXT);

-- USD/BRL Exchange Rate (PTAX)
-- Source: Banco Central do Brasil (BCB), Series 1
-- Daily closing rate used for BRL conversion
CREATE TABLE staging.usd_brl_raw (
    date_text   TEXT,
    usd_brl_text TEXT
);

-- US CPI (Consumer Price Index)
-- Source: FRED / BLS
-- Monthly index, used for reference only (not main deflator)
CREATE TABLE staging.cpi_us_raw (
    observation_date TEXT,
    cpi_us_text      TEXT
);

-- Brazil CPI (IPCA Index)
-- Source: IBGE SIDRA Table 1737
-- Pre-cleaned externally due to formatting issues
CREATE TABLE staging.cpi_br_raw (
    date_text  TEXT,
    cpi_br_text TEXT
);

-- -- TOTAL RETURN MODEL INPUTS ----------------------------------

-- S&P 500 Total Return Index
-- Source: Investing.com (proxy for S&P 500 TR index)
-- Daily series, includes reinvested dividends
CREATE TABLE staging.sp500_tr_raw (
    date_text     TEXT,
    sp500_tr_text TEXT
);

-- IBDS - Ibovespa Total Return Index
-- Source: B3 (Brazilian exchange)
-- Monthly series, includes reinvested dividends
-- Original format: month + year, Brazilian numeric formatting
CREATE TABLE staging.ibds_raw (
    month_text TEXT,
    year_text  TEXT,
    ibds_text  TEXT
);
