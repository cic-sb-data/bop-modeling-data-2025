import duckdb
import pandas as pd
import polars as pl
from pathlib import Path

FOLDER = Path("/sas/data/project/EG/ActShared/ModelCommon/V5.3")
FILENAME = "co_polterms_exper_vars_all_hits.sas7bdat"

CHUNK_SIZE = 1_000_000

df_params={
    'encoding': 'latin-1', 
    'chunksize': CHUNK_SIZE
}

COLS="""
    try_cast(company_numb as utinyint) as company_numb,
    policy_sym as policy_sym,
    try_cast(policy_numb as uinteger) as policy_numb,
    try_cast(policy_module as uinteger) as policy_module,
    try_cast(policy_eff_date as date) as policy_eff_date,
    bin,
    date_of_data,
    date_of_data_dt,
    commercial_intelliscore,
    yearsinfile,
    alltrades,
    baltot,
    ballate_all_dbt,
    numtot_combined,
    baltot_combined,
    judgmentcount,
    liencount,
    bkc006 as bkc006__n_bankruptcies,
    ttc038 as ttc038__n_total_trades,
    ttc039 as ttc039__n_total_trades_where_worst_delinquency_is_current
"""

FIRST_QUERY=f"""CREATE OR REPLACE TABLE raw_tbl AS (
    WITH 
        raw AS (SELECT {COLS} FROM df),
        joined AS (SELECT * FROM raw)

    SELECT *
    FROM joined
);"""

EVERY_OTHER_QUERY=f"""CREATE OR REPLACE TABLE raw_tbl AS (
    WITH 
        cur AS (SELECT * FROM raw_tbl),
        raw AS (SELECT {COLS} FROM df),
        joined AS (SELECT * FROM raw),

        appended AS (
            SELECT * FROM cur 
            UNION ALL  
                SELECT * FROM joined
        )

    SELECT * 
    FROM appended
);"""


def model(dbt, session):
    with duckdb.connect() as conn:
        for df in pd.read_sas(FOLDER / FILENAME, **df_params):
            if counter==1:
                counter += 1
                conn.sql(FIRST_QUERY)
            else:
                conn.sql(EVERY_OTHER_QUERY)

        out = conn.sql("SELECT * FROM raw_tbl").df()

    return out