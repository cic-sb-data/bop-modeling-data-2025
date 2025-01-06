-- DDL for bop modeling data duckdb database
CREATE SCHEMA IF NOT EXISTS raw;

CREATE OR REPLACE VIEW raw.gl_exposureview AS (
    SELECT *
    FROM READ_CSV_AUTO('/sas/data/project/EG/ActShared/SmallBusiness/Modeling/dat/raw_csv/gl_aiv.csv')
);

CREATE OR REPLACE VIEW raw.cf_exposureview AS (
    SELECT *
    FROM READ_CSV_AUTO('/sas/data/project/EG/ActShared/SmallBusiness/Modeling/dat/raw_csv/cf_aiv.csv')
);

CREATE OR REPLACE VIEW raw.ca_exposureview AS (
    SELECT *
    FROM READ_CSV_AUTO('/sas/data/project/EG/ActShared/SmallBusiness/Modeling/dat/raw_csv/ca_aiv.csv')
);

CREATE OR REPLACE VIEW raw.daily_loss_fact AS (
    SELECT *
    FROM READ_CSV_AUTO('/sas/data/project/EG/ActShared/SmallBusiness/Modeling/dat/raw_csv/dlf.csv')
);

CREATE OR REPLACE VIEW raw.experian_credit_vars__2_8 AS (
    SELECT *
    FROM READ_CSV_AUTO('/sas/data/project/EG/ActShared/SmallBusiness/Modeling/dat/raw_csv/experian_credit_vars__2_8.csv')
);

CREATE OR REPLACE VIEW raw.experian_credit_vars__5_2 AS (
    SELECT *
    FROM READ_CSV_AUTO('/sas/data/project/EG/ActShared/SmallBusiness/Modeling/dat/raw_csv/experian_credit_vars__5_2.csv')
);