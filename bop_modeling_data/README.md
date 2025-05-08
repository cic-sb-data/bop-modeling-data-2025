# BOP Modeling Data dbt Project

## Overview

This dbt project, `bop_modeling_data`, is designed to transform and prepare data for a predictive model that assesses policyholder risk, with a specific focus on Non-Payment Cancellation (NPC) events for Business Owner's Policies (BOP). A primary objective is to accurately replicate and potentially improve upon legacy SAS macro logic for calculating prior year NPC counts, which are crucial features for the risk model.

The project ingests data from various SAS-based systems (`screngn`, `decfile`, `modcom`), processes it through a layered modeling approach (raw, staging, lookups, facts, marts), and aims to deliver a reliable `dm__npc_counts` data mart for downstream consumption by analytical models.

## Project Structure

-   **`models/`**: Contains all dbt models, organized into subdirectories representing transformation layers:
    -   `00_raw/`: Ingestion of source data with minimal transformation.
    -   `01_stg/`: Cleaning, standardization, and basic transformations.
    -   `02_lkp/`: Creation of reusable lookup tables.
    -   `03_fct/`: Building fact tables from staged and lookup data.
    -   `05_mrt/`: Final aggregated data marts for analytical consumption (e.g., `dm__npc_counts`).
    -   `07_tmp/`: Temporary or intermediate models, often for complex calculations or checks.
    -   `sources.yml`: Defines the data sources for the project.
-   **`macros/`**: Contains custom dbt macros used throughout the project (e.g., `make_n_prior_year_cols.sql` for prior year calculations).
-   **`tests/`**: Includes dbt tests to ensure data quality, integrity, and consistency:
    -   `generic/`: Custom generic tests.
    -   `singular/`: Specific business logic tests.
    -   Schema tests are also defined within model `.yml` files.
-   **`seeds/`**: For CSV seed files (if any).
-   **`analyses/`**: For ad-hoc analyses (if any).
-   **`snapshots/`**: For dbt snapshots (if any).

## Key Documents

-   **`current-state.md`** (in the root of the repository `/Users/andy/bop-modeling-data-2025/`): Provides a comprehensive summary of the project's current state, including data sources, models, tests, and overall documentation status.
-   **`next-steps.md`** (in the root of the repository `/Users/andy/bop-modeling-data-2025/`): Outlines the detailed checklist and plan for completing the project, focusing on the `dm__npc_counts` model.
-   **`dm__npc_counts__roadmap.md`**: Details the analysis, issues, and strategic plan for improving the `dm__npc_counts` model, particularly its alignment with legacy SAS logic.
-   **`data-testing-plan.md`**: Outlines the comprehensive data testing strategy for the project.
-   **`variables.md`**: Documents the dbt variables used in this project.

## Development Workflow

1.  Ensure your dbt profile (`profiles.yml`, typically located in `~/.dbt/`) is configured correctly for the `bop_modeling_db` target.
2.  Install dependencies: `dbt deps` (if `packages.yml` is updated).
3.  To run models: `dbt run`.
    -   To run a specific model: `dbt run --select my_model_name`.
    -   To run models in a specific folder: `dbt run --select path.to.models`
4.  To run tests: `dbt test`.
    -   To run tests for a specific model: `dbt test --select my_model_name`.
5.  To generate documentation: `dbt docs generate`.
6.  To view documentation locally: `dbt docs serve`.

## Main Goal

The primary deliverable of this project is the `dm__npc_counts` model, which will provide accurate counts of prior non-payment cancellation events for policies, serving as a key input for risk modeling.

### Resources:

-   Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
-   Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
-   Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
-   Find [dbt events](https://events.getdbt.com) near you
-   Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
