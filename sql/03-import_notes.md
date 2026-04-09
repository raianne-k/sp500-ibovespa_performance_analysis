# 03 — Import Notes

This file documents every manual step taken before or during CSV import.
It is the human-readable complement to 02_create_raw_tables.sql.

---

## File inventory

| File                  | Table                    | Source                        | Grain   |
|-----------------------|--------------------------|-------------------------------|---------|
| sp500_daily.csv       | staging.sp500_raw        | FRED (SP500 series)           | Daily   |
| ibov_YYYY.csv (×8)    | staging.ibov_YYYY_raw    | B3 (Ibovespa historical)      | Daily   |
| us_brl_daily.csv      | staging.usd_brl_raw      | BCB Series 1 (PTAX official)  | Daily   |
| cpi_us_monthly.csv    | staging.cpi_us_raw       | FRED (CPIAUCSL series)        | Monthly |
| cpi_br_monthly.csv    | staging.cpi_br_raw       | IBGE SIDRA Table 1737         | Monthly |
| sp500_daily_tr.csv    | staging.sp500_tr_raw     | Investing.com (SPXTR)         | Daily   |
| ibds_monthly.csv      | staging.ibds_raw         | B3 (IBDS total return series) | Monthly |

---

## Manual cleaning performed before import

### SP500 (price)
- File from FRED. Already clean: comma-delimited, UTF-8, YYYY-MM-DD dates.
- No manual changes needed.

### SP500 TR
- File from Investing.com. Format: MM/DD/YYYY dates, values with thousands commas.
- Columns kept: Date, Price only. Open/High/Low/Vol/Change% deleted in Sheets.
- UTF-8 BOM present — stripped on import via utf-8-sig encoding.
- Dates converted from MM/DD/YYYY → YYYY-MM-DD in SQL (see 04_clean_tr_inputs.sql).
- Thousands commas removed via REPLACE() in SQL.

### USD/BRL
- File from BCB (PTAX official rate).
- UTF-8 BOM present — must use utf-8-sig encoding on import.
- Original headers in Portuguese: "DateTime", "Taxa de câmbio nominal".
- Renamed to date, usd_brl before import.

### CPI US
- File from FRED. Already clean.
- No manual changes needed.

### CPI BR
- File from IBGE SIDRA Table 1737. Selected: Número-índice (not % change).
- Original export: wide format, semicolon-delimited, 7 metadata/footer rows.
- Cleaned in Google Sheets:
  - Deleted all metadata rows (title, Fonte, Notas, Legenda)
  - Pivoted wide → long (months as rows)
  - Month labels converted: "janeiro 2019" → 2019-01-01
  - Trailing zeros removed (5116.9300000 → 5116.93)
- Exported as comma-delimited UTF-8 CSV.

### Ibovespa (price)
- Files from B3, one per year.
- Original format: calendar grid (day rows × month columns), semicolon-delimited.
- Title row and blank rows deleted in text editor before import.
- Wide → long reshape done in SQL (see 04_clean_price_inputs.sql).
- Brazilian thousands separator (97,861.28) removed via REPLACE() in SQL.

### IBDS (Ibovespa Total Return)
- File from B3 (IBDS monthly series).
- Encoding: ISO-8859-1 (Latin-1). Import with latin-1 encoding.
- First row is metadata: "IBSD - 1/1/2018 12:00:00 AM..." — deleted before import.
- Columns: Mês (month number), Ano (year), Valor (value).
- Brazilian numeric format: 1.084,01 — dots as thousands, commas as decimals.
- Conversion done in SQL: REPLACE('.','') then REPLACE(',','.').
- Date built from month + year columns in SQL.

---

## Key decisions

- Monthly grain is the primary modeling level.
- Daily market and FX data aggregated using monthly averages.
- Brazilian CPI (IPCA) used to deflate all returns into real BRL terms.
- S&P 500 converted to BRL using monthly average USD/BRL rate.
- Two parallel models maintained: price-based and total-return-based.
- Taxes excluded from main model. Treated as a sensitivity note in Q5.
- Time range: January 2019 – April 2026.
