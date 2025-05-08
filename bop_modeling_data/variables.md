# Project Variables

This document outlines the dbt variables defined in `dbt_project.yml` and used throughout the `bop_modeling_data` project.

## Variable Definitions

Below are the variables currently defined:

*   **`raw_csv_loc`**
    *   **Definition**: `'/sas/data/project/EG/ActShared/SmallBusiness/Modeling/dat/raw_csv'`
    *   **Purpose**: Specifies the base directory path where raw source data, typically in CSV format exported from SAS, is located. Raw models might use this variable to construct full paths to input files.
    *   **Used By**: Primarily raw layer models that ingest data from CSV files.

*   **`decfile_loc`**
    *   **Definition**: `'/sas/data/project/EG/ActShared/SmallBusiness/DecisionSupportFile/Development/2025/20250228'`
    *   **Purpose**: Specifies the directory path for files related to the "Decision File" (`decfile`) source. This is likely a specific version or snapshot of the decfile data.
    *   **Used By**: Raw layer models that ingest data from the `decfile` source.

*   **`policy_eff_date__min_yrmo`**
    *   **Definition**: `200901` (representing January 2009)
    *   **Purpose**: Defines a minimum policy effective date (year-month) used for filtering data. This helps in scoping the data to a relevant historical window for modeling.
    *   **Used By**: Potentially used in staging or lookup models to filter policies based on their effective date, ensuring that only policies effective from this period onwards are included in the analysis.

## Usage in Models

To use these variables in a dbt model, you can reference them using the `var()` function. For example:

```sql
select *
from source('my_source', 'my_table')
where policy_effective_year_month >= {{ var('policy_eff_date__min_yrmo') }}
```

Or, for constructing file paths (example, actual usage might vary based on macros or specific model logic):

```sql
-- Example for a model reading a CSV
-- {{ config(materialized='table') }}

select *
from read_csv_auto('{{ var("raw_csv_loc") }}/my_specific_file.csv')
```

## Management

These variables are defined in the `vars:` section of the `dbt_project.yml` file. Any changes or additions to project-wide variables should be made there and subsequently documented in this file.