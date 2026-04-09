# Data

Data sourced from FRED, BCB, IBGE, and market providers.

## How to get the data

1. You will need the following data sources:

| Series | Source | Identifier |
|--------|--------|------------|
| S&P 500 price | FRED | SP500 |
| S&P 500 total return | Investing.com | SPXTR |
| Ibovespa price | B3 | IBOV |
| Ibovespa total return | B3 | IBDS |
| USD/BRL exchange rate | BCB | PTAX |
| Brazil CPI | IBGE SIDRA | Table 1737 |
| US CPI | FRED | CPIAUCSL |

2. Place all CSV files directly in this `/data` folder

## Files expected by the notebook

| File | Description |
|------|-------------|
| `cpi_br_monthly.csv` | Brazil CPI (monthly, Jan 2019–Feb 2026) — used for inflation adjustment |
| `cpi_us_monthly.csv` | US CPI (monthly, Jan 2019–Feb 2026) — reference inflation series |
| `ibds_monthly.csv` | Ibovespa total return index (monthly, Jan 2019–Feb 2026) |
| `ibov_daily_2019.csv` | Ibovespa price index (daily, Jan 2019–Dec 2019) |
| `ibov_daily_2020.csv` | Ibovespa price index (daily, Jan 2020–Dec 2020) |
| `ibov_daily_2021.csv` | Ibovespa price index (daily, Jan 2021–Dec 2021) |
| `ibov_daily_2022.csv` | Ibovespa price index (daily, Jan 2022–Dec 2022) |
| `ibov_daily_2023.csv` | Ibovespa price index (daily, Jan 2023–Dec 2023) |
| `ibov_daily_2024.csv` | Ibovespa price index (daily, Jan 2024–Dec 2024) |
| `ibov_daily_2025.csv` | Ibovespa price index (daily, Jan 2025–Dec 2025) |
| `ibov_daily_2026.csv` | Ibovespa price index (daily, Jan 2026–Apr 2026) |
| `sp500_daily_tr.csv` | S&P 500 total return index (daily, Jan 2019–Feb 2026) |
| `sp500_daily.csv` | S&P 500 price index (daily, Jan 2019–Feb 2026) |
| `us_brl_daily.csv` | USD/BRL exchange rate (daily, Jan 2019–Feb 2026) |

## License

This repository does not redistribute the original source datasets unless explicitly permitted by their respective providers.

Users are responsible for checking and complying with the licensing and usage terms of each original source before downloading, reproducing, or redistributing the data.

- All series should be aligned at monthly frequency
- Data should be rebased to 100 (Jan 2019)
- Returns should be inflation-adjusted (real terms)

Data sources depend on provider (e.g. FRED, Yahoo Finance, official statistics).  
Ensure compliance with respective licensing terms.