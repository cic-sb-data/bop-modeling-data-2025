# BOP Modeling Data - Current State

This document provides a summary of the `bop_modeling_data` dbt project, outlining its components, data sources, models, tests, and documentation status.

## 1. Project Overview

*   **Project Name**: `bop_modeling_data`
*   **Purpose**: This dbt project is designed to transform and prepare data for a predictive model that assesses policyholder risk, with a specific focus on Non-Payment Cancellation (NPC) events. A key objective is to accurately replicate and potentially improve upon legacy SAS macro logic for calculating prior year NPC counts, which are crucial features for the risk model.
*   **Main Components**:
    *   **dbt Models**: SQL and Python scripts organized into layers (raw, staging, lookups, facts, marts) to progressively transform data.
    *   **dbt Tests**: Schema tests, singular tests, and generic tests to ensure data quality, integrity, and consistency. There is a plan to expand testing using `dbt-expectations`.
    *   **dbt Macros**: Reusable SQL logic encapsulated in macros (e.g., `make_n_prior_year_cols.sql` for prior year calculations).
    *   **Documentation**: Markdown files (e.g., `dm__npc_counts__roadmap.md`, `data-testing-plan.md`) and dbt's integrated documentation features (schema.yml files) to describe the project and its assets.

### 1.1. Definitions
*   **NPC**: Non-Payment Cancellation, a type of policy cancellation due to non-payment of premiums.
*   **BOP**: Business Owner's Policy, a type of insurance policy that combines various coverages into one package.
*   **Policy**: For the purposes of this project, a policy is keyed by what is called the *five key*, and refers to a unique combination of:
    * `company_numb` - The company number associated with the policy.
    * `policy_sym` - The 1-3 character policy symbol.
    * `policy_numb` - The policy number.
    * `policy_module` - The module number with this particular iteration of the policy. In general this increments with each renewal, but there are common exceptions, in particular when policies are cancelled and then reissued. In this case the module may be incremented again, even though the policy number and effective date is the same. There was inconsistent logic in the past, so while this is necessary for uniquely identifying a policy, it should not be given any special meaning beyond that.
    * `policy_eff_date` - The effective date of the policy.

## 2. Data Sources

The project relies on several data sources. Explicit source definitions in `bop_modeling_data/models/sources.yml` are currently minimal and require proper definition. Based on the raw and staging models, the inferred data sources include:

*   **`screngn`**:
    *   **Description**: Tables from the `screngn` (Scoring Engine) library in SAS that contains details about policy-level predictive model scoring, including both input data and output scores. In this case it is primarily used for billing data.
    *   **Referenced by**: Raw models in `bop_modeling_data/models/00_raw/billing/` (e.g., `raw__screngn__xcd_bil_account.sql`, `raw__screngn__xcd_bil_act_summary.sql`).
    *   **Current Status**: Actively used, but formal source definition in `sources.yml` is needed. Raw models are developed on exported CSV data from SAS, and are being transformed into staging models.
*   **`decfile`**:
    *   **Description**: Short for "Decision File," this source contains policies specifically identified as similar enough to small business policies to be used for modeling purposes. It includes data such as policy lookups and AIV (Analytic Image Views) lookups.
    *   **Referenced by**: Raw models in `bop_modeling_data/models/00_raw/decfile/` (e.g., `raw__decfile__sb_aiv_lookup.sql`, `raw__decfile__sb_policy_lookup.sql`).
    *   **Current Status**: Actively used, formal source definition may be needed given it direct source from exported CSV data from SAS.
*   **`modcom`**:
    *   **Description**: "Model Common" data, providing shared datasets like policy chain information.
    *   **Referenced by**: `bop_modeling_data/models/00_raw/modcom/raw__modcom__policy_chain_v3.py`.
    *   **Current Status**: Actively used, formal source definition needed. Pulled directly from the SAS `MODCOM` library.
*   **`current_cincibill` (cur_cb)**:
    *   **Description**: This is a reproduction of the current Cincibill data processing for generation 1.5 BOP modeling. CinciBill is our billing system.
    *   **Referenced by**: Staging models in `bop_modeling_data/models/01_stg/current_cincibill/` (e.g., `stg__cur_cb.sql`). The exact raw source tables feeding this are transformed from `screngn` or a similar system.
    *   **Current Status**: Used in staging, but the source is not explicitly defined in `sources.yml`. It is a transformation of the `screngn` data, and uses the *__xcd_bil_* subset of `screngn` tables as its source.

## 3. Models

The dbt models are organized into layers, reflecting the data transformation pipeline:

### Raw Layer (`bop_modeling_data/models/00_raw/`)
*Purpose: Ingests data from source systems with minimal transformation.*
*   **`billing/raw__screngn__*.sql`**: A series of models ingesting various tables from the `screngn` SAS library (mostly re: billing detail -- e.g., account details, activity summaries, cash receipts, policy terms).
*   **`decfile/raw__decfile__*.sql`**: Models ingesting tables from the BOP decision file data processing (e.g., `raw__decfile__sb_policy_lookup.sql`, `raw__decfile__sb_aiv_lookup.sql`).
*   **`modcom/raw__modcom__policy_chain_v3.py`**: A Python model for ingesting `policy_chain_v3` data directly from the `modcom` SAS library.

### Staging Layer (`bop_modeling_data/models/01_stg/`)
*Purpose: Cleans, standardizes, and prepares raw data for further transformation (e.g., renaming, casting, basic joins).*
*   **`current_cincibill/stg__cur_cb__*.sql`**: Stages data related to "current Cincibill," which attempts to replicate the current Cincibill data processing for generation 1.5 BOP modeling. This includes staging billing account details, activity summaries, and cash receipts.
*   **`decfile/stg__decfile__sb_policy_lookup.sql`**: Stages `sb_policy_lookup` data from `decfile`, and defines the subset of policies to be used in the modeling process. Includes the policy chain ID for getting previous policy information on renewal accounts.
*   **`modcom/stg__modcom__policy_chain_v3.sql`**: Stages `policy_chain_v3` data, and filters it to include only the relevant policies for the modeling process.
*   **`screngn/stg__screngn__*.sql`**: Multiple models staging various tables from the `screngn` billing system, often involving renaming and casting.

### Lookup Layer (`bop_modeling_data/models/02_lkp/`)
*Purpose: Creates reusable lookup tables, often dimensional, to enrich fact tables.*
*   **`lkp__associated_policies.sql`**: A critical model that links small business policy keys (`sb_policy_key`) to their broader policy chain information. This includes all associated policy keys within that chain and their respective effective dates.
*   **`lkp__billing_policies.sql`**: Associates billing data with policies, likely linking `sb_policy_key` to billing system keys.
*   **`lkp__dates.sql`**: Generates a date dimension table, potentially including prior year flags or calculations.
*   **`lkp__first_billing_activity_date.sql`**: Determines the first billing activity date for relevant entities.
*   **`lkp__policy_chain_ids.sql`**: Processes and provides distinct policy chain identifiers and associated counts.
*   **`lkp__sb_policy_key.sql`**: Provides a lookup for small business policy keys, possibly sourced from `decfile`.

### Fact Layer (`bop_modeling_data/models/03_fct/`)
*Purpose: Creates fact tables by joining data from lookup and staging layers to record business events or transactions.*
*   **`fct__associated_policy_eff_date.sql`**: Creates a fact table related to associated policy effective dates, likely joining `lkp__associated_policies` with `lkp__dates`.
*   **`fct__billing_activity.sql`**: Consolidates and prepares detailed billing activity data, creating a unique key (`activity_trans_key`) for each transaction. This is a core input for NPC calculations.
*   **`fct__prior_activity_dates.sql`**: Calculates prior activity dates relative to policy effective dates, likely utilizing the `make_n_prior_year_cols` macro to determine if activities fall into specific prior year windows.

### Mart Layer (`bop_modeling_data/models/05_mrt/`)
*Purpose: Final, aggregated data marts designed for consumption by downstream processes, such as predictive models or business intelligence tools.*
*   **`dm__npc_counts.sql`**: The primary mart model of interest. It calculates the total number of non-payment cancellation (NPC) events for each `sb_policy_key` within one to five years immediately preceding the policy's effective date. This model is currently undergoing significant review and refactoring to ensure performance and alignment with legacy SAS logic as detailed in `dm__npc_counts__roadmap.md`.

### Temporary/Check Models
*   **`bop_modeling_data/models/07_tmp/lkp__associated_policies_counts/`**: Contains several ephemeral models (e.g., `_lkp__associated_policies_counts__add_final_associated_policy_key.sql`) used as intermediate steps in calculating row counts for `lkp__associated_policies`, primarily for validation.
*   **`bop_modeling_data/chk__lkp__associated_policies__row_counts.sql`**: A model designed to perform row count checks related to the `lkp__associated_policies` model and its constituent CTEs.

## 4. Tests

The project includes a testing framework to ensure data quality and integrity. A detailed testing strategy is outlined in `bop_modeling_data/data-testing-plan.md`.

*   **Directory**: `bop_modeling_data/tests/`
*   **Generic Tests (`tests/generic/`)**:
    *   `assert_foreign_keys_are_present.sql`: A custom generic test to ensure that all foreign key values in a child table column exist in the corresponding parent table column.
*   **Singular Tests (`tests/singular/`)**:
    *   `assert_dm_npc_counts_referential_integrity.sql`: Ensures that every `sb_policy_key` in `dm__npc_counts` exists in `lkp__associated_policies` and that their `policy_eff_date` values match.
    *   `assert_lkp_associated_policies_coverage.sql`: Validates that `lkp__associated_policies` includes all relevant `sb_policy_key`s from its source (decfile) that have a `policy_chain_id`, and that all `policy_chain_id`s in `lkp__associated_policies` exist in the source policy chain model (modcom).
*   **Schema Tests**: Defined in various `_schema.yml` files within the `bop_modeling_data/models/` subdirectories. These typically include `not_null`, `unique`, `accepted_values`, and `relationships` tests.
*   **Planned Expansion**: The `dm__npc_counts__roadmap.md` (Section 7) and `data-testing-plan.md` detail plans to significantly expand data testing, particularly by leveraging the `dbt-expectations` package for more sophisticated column-level and table-level assertions.

## 5. Documentation

Various forms of documentation exist within the project to explain its structure, logic, and goals.

*   **Project-Level Documentation (in `/Users/andy/bop-modeling-data-2025/`)**:
    *   `README.md`: Standard dbt project README at the root of the dbt project.
    *   `profiles-sample.yml`: Sample configuration for dbt profiles.
    *   `pyproject.toml`: Python project configuration (e.g., for `uv` lock file, `ruff` linter).
    *   `CHECKING.md`: Contains general guidelines and reminders for data checking and validation.
    *   `duckdb-schema.md`: Describes the schema of the DuckDB development database.
    *   `variables.md`: Intended for dbt variable definitions. **Status: Minimal (contains only "-"); needs to be populated or confirmed if not used.**
*   **dbt Project Specific Documentation (in `/Users/andy/bop-modeling-data-2025/bop_modeling_data/`)**:
    *   `README.md`: A brief, possibly placeholder README for the `bop_modeling_data` dbt project itself. **Status: Could be expanded.**
    *   `dbt_project.yml`: The main configuration file for the dbt project.
*   **Analysis, Planning, and Strategy Documents**:
    *   `dm__npc_counts__roadmap.md`: A comprehensive document detailing the analysis, identified issues, and strategic plan for improving the `dm__npc_counts` model. It focuses on aligning the model with legacy SAS business logic and improving performance. **Status: Appears detailed and current for its purpose.**
    *   `data-testing-plan.md`: A thorough plan outlining the data testing strategy for the entire dbt project, including methodologies for different model layers and the use of various dbt testing packages. **Status: Appears well-defined.**
*   **Model and Schema Documentation (dbt Docs)**:
    *   `_schema.yml` files: Located within model subdirectories (e.g., `bop_modeling_data/models/00_raw/billing/_schema.yml`, `bop_modeling_data/models/05_mrt/_schema.yml`). These files contain descriptions for models and their columns, and define schema tests. **Status: Present for most model groups, but completeness of descriptions varies. Ongoing effort needed, especially with the planned integration of `dbt-expectations`.**
    *   `models/00_raw/billing/_docs.md`: An example of an embedded documentation block (markdown) used within a schema file to provide more detailed descriptions.
*   **Supporting Markdown Documents (in `/Users/andy/bop-modeling-data-2025/`)**:
    *   `lkp__associated_policies.md`: Likely contains specific documentation for the `lkp__associated_policies` model. **Status: Needs review for content, completeness, and integration with dbt docs.**
    *   `npc-counts.md`: Likely contains information, analysis, or notes related to NPC counts. **Status: Needs review for current relevance, completeness, and potential integration into dbt docs or the roadmap.**
*   **External Documentation**:
    *   `bop_modeling_data/Billing Data Model 2-4-1.pdf`: An external PDF document, likely providing business context, data dictionary, or specifications for the source billing data model.
*   **Areas for Documentation Improvement**:
    *   **`bop_modeling_data/models/sources.yml`**: Critically needs to be populated with formal definitions for all data sources.
    *   **`variables.md`**: Populate with dbt variable definitions if used, or clarify if not.
    *   **`_schema.yml` files**: Systematically review and complete model and column descriptions across all schema files.
    *   **Markdown Files (`lkp__associated_policies.md`, `npc-counts.md`)**: Review, update, and integrate their content into the dbt docs where appropriate.
    *   **`bop_modeling_data/README.md`**: Enhance with a more specific overview of this dbt project.
    *   **Inline Model Comments**: Ensure complex logic within SQL models is adequately commented.
