import polars as pl
from pathlib import Path

ROOT_DIR = Path("/sas/data/project/EG/ActShared/SmallBusiness/Modeling/dat/raw_csv")
FILE = "experian_credit_vars__2_8.csv"

def read_csv(file):
    return pl.scan_csv(
        file,
        with_column_names=lambda cols: [col.lower() for col in cols],
        infer_schema_length=1_000_000,
        null_values=["-"]
    ).collect().to_pandas()


def model(dbt, session):
    return read_csv(ROOT_DIR / FILE)

# COLUMN_LIST = [
#     "COMPANY_NUMB",
#     "POLICY_SYM",
#     "POLICY_NUMB",
#     "POLICY_MODULE",
#     "POLICY_EFF_DATE",
#     "BIN",
#     "DATE_OF_DATA",
#     "YEARSINFILE",
#     "commercial_intelliscore",
#     "ALLTRADES",
#     "BALTOT",
#     "ballate_all_dbt",
#     "numtot_combined",
#     "baltot_combined",
#     "JUDGMENTCOUNT",
#     "LIENCOUNT",
#     "bkc006",
#     "bkc007",
#     "bkc008",
#     "bko009",
#     "BKB001 Sign",
#     "BKB001",
#     "BKB003 Sign",
#     "BKB003",
#     "BKO010",
#     "BKO011",
#     "BKC004",
#     "BKC005",
    
#     "TTC035",
#     "TTC036",
#     "TTC037",
#     "TTC051",
#     "TTC052",
#     "TTC053",
#     "TTC054",
#     "TTC055",
#     "TTC056",
#     "TTC057",
#     "TTC058",
#     "TTC059",
#     "TTC060",
#     "TTC038",
#     "TTC039",
#     "TTC040",
#     "TTC041",
#     "TTC042",
#     "TTC043",
#     "TTC044",
#     "TTC045",
#     "TTC046",
#     "TTC047",
#     "TTC048",
#     "TTC049",
#     "TTC061",
#     "TTC063",
#     "TTC064",
#     "TTC065",
#     "TTC066",
#     "TTC067",
#     "TTC068",
#     "TTC069",
#     "TTC070",
#     "pay_sat",
#     "Percentile",
#     "INTELLISCORE_SCORE_FACTOR1",
#     "INTELLISCORE_SCORE_FACTOR2",
#     "INTELLISCORE_SCORE_FACTOR3",
#     "INTELLISCORE_SCORE_FACTOR4",
#     "Executive Count",
#     "Derogatory Indicator",
#     "Number of Derogatory Legal Items",
#     "Derogatory Liability Amount Sign",
#     "Derogatory Liability Amount",

#     "IQC001",
#     "IQC002",
#     "IQC003",

#     "Recent High Credit Sign",
#     "Recent High Credit",
#     "Median Credit Amount Sign",
#     "Median Credit Amount",
#     "Total Combined Trade Lines",
#     "DBT of Combined Trade Totals",
#     "Combined Trade Balance",
#     "Aged Trade Lines",
#     "CTB006-CTB001",
#     "CTB003-CTB001",
#     "CTB0045-CTB001",
#     "Experian Credit Rating",
#     "Collection count",
#     "Cottage Indicator",
#     "Score   Model Sign 113",
#     'Score 113',
#     'Percentile model 113',
#     'Model action',
#     'Score Factor 1',
#     'Score Factor 2',
#     'Score Factor 3',
#     'Score Factor 4',
#     'Model Code',
#     'Model type',
#     'Score   Model Sign 210',
#     'Score 210',
#     'Percentile model 210',
#     'Model action',
#     'Score Factor 1',
#     'Score Factor 2',
#     'Score Factor 3',
#     'Score Factor 4',
#     'Model Code',
#     'Model type',
#     'Score   Model Sign 214',
#     'Intelliscore Plus 214',
#     'Percentile model',
#     'Model action',
#     'Score Factor 1',
#     'Score Factor 2',
#     'Score Factor 3',
#     'Score Factor 4',
#     'Model Code',
#     'Model type',
#     'Last Experian Inquiry Date',
# ]

