# Real Return Divergence — S&P 500 vs Ibovespa (BRL)

**Role:** Data Analytics  
**Domain:** Financial Markets / Macro  
**Tools:** SQL (PostgreSQL + DBeaver), Tableau  
**Datasets:** Public market data (S&P 500 TR, Ibovespa, USD/BRL, CPI)  
**Dashboard:** *(see /assets/S&P 500 vs Ibovespa (2019-2026).png)*

---

## Business Context

This project evaluates which market delivered stronger real returns for a Brazilian investor across the pandemic cycle from 2019 to 2026.
Despite strong global market performance, Brazilian investors experienced materially weaker real returns in local currency terms.

This analysis investigates when that occurred, what drove it, and whether it holds under realistic investment conditions.

---

## Guiding Questions

1. Which market delivered stronger real returns for a Brazilian investor (S&P 500 vs Ibovespa)?
2. When did the divergence occur across market phases (pre, shock, recovery, post)?
3. To what extent was the gap driven by market performance vs currency effects?
4. Does the result hold after accounting for real-world frictions (tax, FX, access)?

---

## Key Findings

- S&P 500 delivered ~180% real returns vs ~40% for Ibovespa (BRL-adjusted)
- Most divergence occurred during the 2020–2022 shock and recovery phases
- BRL depreciation significantly amplified USD-denominated returns
- Ibovespa outperformed post-2023 (~51% vs ~24%), but too late to close the gap
- Even after taxes, FX costs, and access frictions, S&P remained materially ahead

---

## Methodology

- All series rebased to 100 (Jan 2019)  
- Returns expressed as real (inflation-adjusted) using Brazilian CPI  
- S&P 500 converted to BRL using USD/BRL exchange rate  
- Monthly aggregation used across all series  
- Phase segmentation: pre, shock, recovery, post  
- Friction scenarios include:
  - capital gains tax (15%–22.5%)
  - FX spread (1–3%)
  - ETF annual fees (0.3%–0.7%)

Data sourced from public, more details on 'data_README.md'.

---

## Pipeline

Data processing and analysis performed in PostgreSQL using a structured pipeline:

- Data cleaning and type casting  
- Monthly aggregation and alignment  
- Index construction (price and total return)  
- Real return calculation  
- Final analytical queries (1-5)

---

## Repository Structure

- README.md — project overview  
- /sql — data modeling and analysis queries  
- /data — dataset instructions  
- /viz — Tableau workbook  
- /assets — dashboard image and summary  

---

## Dataset

Market data is not included in this repository.

To reproduce:

- S&P 500 Total Return index  
- Ibovespa index  
- USD/BRL exchange rate  
- Inflation (CPI)  

---

## Limitations

- Tax treatment modeled as simplified flat rates  
- FX uses official rates; retail spreads may vary  
- Assumes continuous holding (no behavioral effects)  
- Results are sensitive to time period (2019–2026)

---

## About This Project

This case study demonstrates end-to-end analytical thinking applied to financial markets.

It combines data modeling, economic reasoning, and visualization to explain not just what happened, but when and why divergence occurred, and whether conclusions hold under realistic investor conditions.