import polars as pl
import pandas as pd

def read_csv(file):
    return pl.scan_csv(
        file,
        with_column_names=lambda cols: [col.lower() for col in cols],
        infer_schema_length=1_000_000,
        null_values=["-"]
    ).collect().to_pandas()

def model(dbt, session):
    return pd.DataFrame({
        "python_funcs": [
            "read_csv"
        ]
    })