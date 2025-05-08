# Project Variables

This file documents the dbt project variables defined in `bop_modeling_data/dbt_project.yml`. These variables are used to configure paths and parameters within the dbt models.

## Variable Definitions

*   `raw_csv_loc`:
    *   **Value**: `/sas/data/project/EG/ActShared/SmallBusiness/Modeling/dat/raw_csv`
    *   **Description**: Specifies the directory path where raw CSV data files, exported from SAS, are located. These files serve as the initial input for the `00_raw` layer models that ingest data from the `screngn` source system.
*   `decfile_loc`:
    *   **Value**: `/sas/data/project/EG/ActShared/SmallBusiness/DecisionSupportFile/Development/2025/20250228`
    *   **Description**: Specifies the directory path for the "Decision File" data. This location contains data related to policies identified for modeling, including policy lookups and AIV (Analytic Image Views) lookups. Raw models in `00_raw/decfile/` use this path.
*   `policy_eff_date__min_yrmo`:
    *   **Value**: `200901`
    *   **Description**: Defines the minimum policy effective date (YearMonth format, e.g., YYYYMM) to be included in the modeling dataset. This variable is likely used to filter policies in staging or lookup models to ensure only relevant historical data is processed. For example, it might be used in `stg__decfile__sb_policy_lookup` or `lkp__dates`.
