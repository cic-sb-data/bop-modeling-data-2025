import polars as pl
from pathlib import Path

ROOT_DIR = Path("/sas/data/project/EG/ActShared/SmallBusiness/Modeling/dat/raw_csv")
FILE = "dlf.csv"

def read_csv(file):
    return pl.scan_csv(
        file,
        with_column_names=lambda cols: [col.lower() for col in cols],
        infer_schema_length=1_000_000,
        null_values=["-"]
    ).collect().to_pandas()


def model(dbt, session):
    return read_csv(ROOT_DIR / FILE)