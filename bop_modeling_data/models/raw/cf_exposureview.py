import polars as pl
from pathlib import Path

FOLDER = Path(__file__).parent


def model(dbt, session):
    FILENAME = FOLDER / "data" / "cf_aiv.csv"
