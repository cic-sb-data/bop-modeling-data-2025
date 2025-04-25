import logging
import duckdb
import pandas as pd
import polars as pl
from pathlib import Path

logger = logging.getLogger(__name__)
logging.basicConfig(filename="temp.log")

EGSB = Path("/sas/data/project/EG/ActShared/SmallBusiness/Modeling/dat")
MODCOM = Path("/sas/data/project/EG/ActShared/ModelCommon")
FILENAME = "policy_chain_v3.sas7bdat"

CHUNK_SIZE = 1_000_000

JOIN_PART="""
    policy_syms AS (SELECT * FROM pol_syms),
    joined AS (
        SELECT raw.*

        FROM raw
        INNER JOIN policy_syms
            ON raw.policy_sym = policy_syms.policy_sym)"""

logger.info(f"JOIN_PART: {JOIN_PART}")

COLS = """try_cast(policy_chain_id as uinteger) as policy_chain_id,
    try_cast(company_numb as utinyint) as company_numb,
    policy_sym as policy_sym,
    try_cast(policy_numb as uinteger) as policy_numb,
    try_cast(policy_module as uinteger) as policy_module,
    try_cast(policy_eff_date as date) as policy_eff_date"""

logger.info(f"COLS: {COLS}")

FIRST_QUERY=f"""CREATE OR REPLACE TABLE raw_tbl AS (
    WITH 
        raw AS (SELECT {COLS} FROM df),
        joined AS (SELECT * FROM raw)

    SELECT *
    FROM joined
);"""

logger.info(f"FIRST_QUERY: {FIRST_QUERY}")

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

logger.info(f"EVERY_OTHER_QUERY: {EVERY_OTHER_QUERY}")

df_params={
    'encoding': 'latin-1', 
    'chunksize': CHUNK_SIZE
}


def model(dbt, session):
    counter = 1
    with duckdb.connect() as conn:
        for df in pd.read_sas(MODCOM / FILENAME, **df_params):
            if counter==1:
                counter += 1
                conn.sql(FIRST_QUERY)
            else:
                conn.sql(EVERY_OTHER_QUERY)

        out = conn.sql("SELECT * FROM raw_tbl").df()

    return out