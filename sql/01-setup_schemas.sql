----------------------------------------------------------------
-- 01-setup_schemas.sql
-- Schemas to separate raw tables in staging from analytics.
----------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;
