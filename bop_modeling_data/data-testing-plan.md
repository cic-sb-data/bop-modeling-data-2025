# Data Testing Plan for BOP Modeling Data

## 1. Introduction

This document outlines the data testing plan for the `bop_modeling_data` dbt project. The goal is to ensure data accuracy, integrity, and reliability throughout the data transformation pipeline, from raw data ingestion to the final data marts. This plan emphasizes:

1.  **AIV Value Matching**: Rigorous checks for fields expected to match AIV (Automated Insurance Value) data at multiple stages.
2.  **Aggregate Premium/Loss Validation**: Verification of summed monetary values (like premium and loss components) at key aggregation points.
3.  **Key Integrity**: Ensuring that primary, foreign, and surrogate keys are correctly generated, populated, and that no records are unintentionally lost during joins or transformations.

This plan leverages dbt's built-in testing capabilities, along with functionalities from installed packages such as `dbt_utils`, `dbt_profiler`, `testgen`, and `dbt_eda_tools`.

## 2. General Testing Principles

*   **Test Incrementally**: Implement tests at each significant layer of transformation (Raw, Staging, Lookup, Fact, Mart).
*   **Focus on Critical Data**: Prioritize testing for key identifiers, AIV-related fields, monetary amounts, and fields crucial for modeling.
*   **Automate**: Utilize dbt tests (schema, singular, generic) for automation and integration into the dbt workflow (`dbt test`).
*   **Document**: Clearly define the purpose, expected outcome, and implementation details for each test.
*   **Iterate**: Continuously review and enhance tests as the data or business logic evolves. Use tools like `testgen` to discover new test cases.
*   **Profile Data**: Regularly use `dbt_profiler` or `dbt_eda_tools` on key models to understand data distributions, identify anomalies, and detect data drift.

## 3. Installed Packages and Their Roles

*   **`dbt_utils`**: For common data tests (e.g., `not_null`, `unique`, `accepted_values`, `relationships`, `equality`) and utility macros.
*   **`dbt_profiler` / `dbt_eda_tools`**: For generating comprehensive data profiles (min, max, mean, distinct counts, distributions, null rates) to understand data quality and identify outliers.
*   **`testgen`**: For automatically generating basic schema tests (e.g., `not_null`, `unique`, `accepted_values` based on existing data patterns), which can be a good starting point.
*   **`codegen`**: Useful for generating boilerplate for new models or sources, can also help in drafting test YAML structures.
*   **Existing Custom Tests**: Leverage and expand upon tests in `tests/generic/` and `tests/singular/`.

## 3.1. Package-Specific Testing Strategies

This section details how the unique capabilities of each installed dbt package will be strategically employed to enhance the data testing process.

*   **`dbt-labs/dbt_utils` (version 1.3.0)**:
    *   **Strategy**: This is a foundational package providing a wide array of generic tests and macros.
    *   **Key Tests to Use**:
        *   `unique`: For all primary key columns (e.g., `sb_policy_key` in `stg__decfile__sb_policy_lookup`, `activity_trans_key` in `fct__billing_activity`).
        *   `not_null`: For all columns that are critical and should never be empty (e.g., key components, core date fields, monetary amounts where applicable).
        *   `accepted_values`: For categorical columns with a known, fixed set of valid entries (e.g., status codes, type codes, AIV-related flags if they have defined enumerations).
        *   `relationships`: To assert referential integrity between tables (e.g., `fct__billing_activity.associated_policy_key` must exist in `lkp__associated_policies.associated_policy_key`). This will be crucial for ensuring no orphaned records.
        *   `equality`: To compare transformed data with its source if no change in value is expected (e.g., comparing an AIV field in a staging model to its counterpart in the raw layer if only casting occurred).
        *   `expression_is_true`: For custom logic checks, e.g., ensuring `end_date >= start_date`.
    *   **Macros**: Utility macros like `dbt_utils.star()` for selecting columns or `dbt_utils.surrogate_key()` for generating keys (though the project seems to have custom key macros already, `dbt_utils` can supplement if needed).

*   **`dbt-labs/dbt_project_evaluator` (version 1.0.0)**:
    *   **Strategy**: This package is primarily for auditing the dbt project structure, adherence to best practices, and documentation coverage. While not directly testing data values, it ensures the project's maintainability and reliability, which indirectly supports data quality.
    *   **Key Uses**:
        *   Run periodically to identify models lacking documentation or tests.
        *   Check for unused sources or models.
        *   Ensure consistent naming conventions.
        *   This will help maintain a high standard for the dbt project itself, making it easier to implement and trust the data tests.

*   **`dbt-labs/codegen` (version 0.13.1)**:
    *   **Strategy**: `codegen` helps generate boilerplate dbt code, including model YAML files and source definitions.
    *   **Key Uses**:
        *   When adding new models, use `codegen` to quickly create the initial YAML structure.
        *   Use `codegen.generate_model_yaml` and then manually add tests to the generated columns. This speeds up the process of defining tests for new models.
        *   Can be used to generate `sources.yml` entries, which is the first step before testing raw data.

*   **`data-mie/dbt_profiler` (version 0.8.4)** / **`shankararul/dbt_eda_tools` (version 1.3.6)**:
    *   **Strategy**: These packages provide tools for Exploratory Data Analysis (EDA) and data profiling directly within dbt. They generate comprehensive statistics about the data in models.
    *   **Key Uses**:
        *   **Initial Data Understanding**: Profile raw source tables to understand initial data distributions, null percentages, cardinality, min/max values, etc. This is crucial for AIV fields and monetary amounts.
        *   **Transformation Impact Assessment**: Profile models at different layers (staging, fact, mart) to see how transformations affect data characteristics. For example, check if a join unexpectedly increased nulls or if a filter drastically changed the range of a monetary field.
        *   **Anomaly Detection**: Regularly profile key fact and mart tables to spot anomalies or data drift over time. For example, if the average `billing_activity_amt` suddenly changes significantly.
        *   **Test Value Discovery**: Use profiles to identify potential `accepted_values` for columns or to set reasonable thresholds for range checks.
        *   `dbt_profiler` can be run via `dbt run-operation` commands. `dbt_eda_tools` might offer macros to embed EDA directly into models or analyses. The choice between them or using both will depend on the specific output and ease of use for different scenarios.

*   **`kgmcquate/testgen` (version 1.0.3)**:
    *   **Strategy**: `testgen` automatically generates basic dbt data tests (like `not_null`, `unique`, `accepted_values`, `relationships`) based on the existing data in your models.
    *   **Key Uses**:
        *   **Bootstrap Testing**: Run `testgen` on existing models, especially in the raw and staging layers, to quickly establish a baseline set of tests.
        *   **Discover Implicit Rules**: It can help uncover data rules that are implicitly present in the data but not yet formally documented or tested (e.g., a column that happens to be unique or always non-null).
        *   **Augment Manual Tests**: Use `testgen` output as a starting point and then refine the generated tests, adding more specific logic or business context. For example, `testgen` might suggest `accepted_values` based on current data, but these might need to be expanded based on domain knowledge.

*   **`sdebruyn/dbt_duckdb_utils` (version 0.1.1)**:
    *   **Strategy**: Provides utility functions and macros specifically for dbt projects using DuckDB.
    *   **Key Uses**:
        *   Review available macros for any performance optimizations or DuckDB-specific SQL functions that could simplify test queries or model logic.
        *   For example, if there are macros for complex type handling or specific aggregate functions in DuckDB that are more efficient than standard SQL, they could be used in test definitions.

*   **`calogica/dbt_date` (version 0.10.1)**:
    *   **Strategy**: This package offers macros for date and time manipulations, which are often complex and error-prone.
    *   **Key Uses**:
        *   **Consistent Date Logic**: If tests involve date comparisons, calculations (e.g., checking if `billing_activity_date` falls within a certain range relative to `policy_eff_date`), or transformations, use macros from this package to ensure consistency and correctness.
        *   **Simplify Date-Related Tests**: Macros like `dbt_date.n_days_ago`, `dbt_date.is_weekend`, or date spine generators can be useful in constructing specific test scenarios or generating test data for date dimension checks.
        *   The project already has custom date logic (e.g., `lkp__dates`). This package can supplement or provide more robust alternatives for specific date calculations needed in tests.

By strategically combining these packages, the data testing plan aims to be comprehensive, efficient, and robust, covering everything from basic schema checks to complex business rule validations.

## 4. Step-by-Step Testing Checklist

### Phase 1: Raw Layer (`models/00_raw/`)

**Objective**: Ensure raw data is ingested correctly and basic data properties are met. The primary source for AIV values is likely `raw__decfile__sb_aiv_lookup.sql`.

**General Actions for all Raw Models**:
*   Use `dbt_profiler` or `dbt_eda_tools` to generate initial profiles for all raw tables. Pay attention to null percentages, distinct counts, and basic statistics for all columns.
*   For files read by `read_csv_auto`, verify that data types are inferred reasonably.

**Specific Model Checks**:

1.  **`raw__decfile__sb_aiv_lookup.sql` (Critical for AIV)**
    *   **AIV Fields**: Identify all columns representing AIV data.
        *   For each AIV field:
            *   Test for `not_null` if applicable using `dbt_utils.not_null`.
            *   If AIV fields have a known set of discrete values, use `dbt_utils.accepted_values`.
            *   Profile distributions to understand typical values.
    *   **Key Fields**:
        *   If there's a primary key for AIV records, test for `unique` and `not_null`.

2.  **`raw__decfile__sb_policy_lookup.sql` & `raw__decfile__screngn_policy_lookup.sql`**
    *   **Key Fields** (`sb_policy_key`, `policy_chain_id`, policy five-key components):
        *   Test for `not_null` on essential key components.
        *   Profile `sb_policy_key` and `policy_chain_id` for uniqueness or expected duplication patterns.

3.  **`raw__screngn__xcd_bil_policy.sql` (and other `screngn` billing tables)**
    *   **Key Fields** (`bil_account_id`, `XCD_POLICY_ID`, date fields):
        *   Test for `not_null`.
        *   Profile for uniqueness where expected.
    *   **Monetary Fields** (e.g., amounts in `raw__screngn__xcd_bil_act_summary.sql`):
        *   Profile for range and distribution. Check for unexpected negatives or extreme values.
    *   **Date Fields**:
        *   Profile to ensure dates are within expected ranges.

4.  **`raw__modcom__policy_chain_v3.py` (Python model output)**
    *   Since this is a Python model, the actual testing will occur on its materialized dbt model (`stg__modcom__policy_chain_v3.sql`). However, ensure the Python script itself has logging for record counts processed from the SAS file.

### Phase 2: Staging Layer (`models/01_stg/`)

**Objective**: Verify transformations (renaming, casting, hashing, basic joins) are correct and data quality is maintained or improved.

**General Actions for all Staging Models**:
*   Compare row counts with corresponding raw tables, accounting for any `distinct` operations or filters.
*   Verify data types after casting operations.
*   Re-profile columns that underwent transformation using `dbt_profiler`.

**Specific Model Checks**:

1.  **`stg__decfile__sb_policy_lookup.sql`**
    *   **AIV Field Propagation**: If AIV fields are passed from `raw__decfile__sb_aiv_lookup` (or if this model itself contains AIV fields from `raw__decfile__sb_policy_lookup.csv`):
        *   Use `dbt_utils.equality` to compare values with the raw source if no transformation is expected.
        *   Verify data types and distributions.
    *   **Key Integrity**:
        *   `sb_policy_key`: Test `not_null`, `unique`.
        *   `policy_chain_id`, `company_numb`, `policy_sym`, `policy_numb`, `policy_module`, `policy_eff_date`: Test `not_null`.

2.  **`stg__modcom__policy_chain_v3.sql`**
    *   **Key Integrity**:
        *   `policy_chain_id`: Test `not_null`.
        *   Policy five-key components: Test `not_null`.
        *   `five_key_hash`, `three_key_hash`: Test `not_null`. If expected to be unique per policy instance, test for `unique`.
    *   **Row Counts**: Ensure `distinct` operation behaves as expected.
    *   **Date Casting**: Verify `policy_eff_date` is correctly cast and reasonable.

3.  **`stg__screngn__*` models (e.g., `stg__screngn__xcd_bil_act_summary.sql`)**
    *   **AIV Field Checks**: If any fields from these staging models are used in conjunction with or are expected to align with AIV data downstream, note them for cross-validation.
    *   **Key Hashing** (e.g., `bil_account_id_hash`): Test for `not_null`.
    *   **Date Transformations** (e.g., `recode__sas_date_format` macro):
        *   Verify output dates are correct and in the expected format. Test for `not_null` if applicable.
        *   Test boundary conditions for date transformations if possible.
    *   **Monetary Fields**: Check that sums are preserved from raw if no filtering occurred, or that transformations are correct.

4.  **`stg__cur_cb.sql`**
    *   **Join Integrity**: This model joins `lkp__billing_policies` and `stg__cur_cb__xcd_bil_act_summary`.
        *   Test relationship `billing_acct_key` to `lkp__billing_policies.billing_acct_key` using `dbt_utils.relationships`.
        *   Ensure no unexpected row loss or duplication due to joins. Check row counts before and after the join.
    *   **Filtering Logic**: Verify the `where billing_activity_desc_cd='C' and billing_activity_desc_reason_type is null` clause.

### Phase 3: Lookup Layer (`models/02_lkp/`)

**Objective**: Ensure lookup tables are correctly constructed, comprehensive, and maintain referential integrity. These are critical for joining data correctly in downstream models.

1.  **`lkp__associated_policies.sql` (Highly Critical)**
    *   **AIV Field Alignment**: `policy_eff_date` is a key component. If AIV data is tied to specific effective dates, ensure this field is accurate and consistent.
    *   **Key Integrity**:
        *   Test `unique_key=['associated_policy_key', 'associated_sb_policy_key']` (as configured).
        *   `associated_sb_policy_key`: Test `not_null`. Test relationship to `stg__decfile__sb_policy_lookup.sb_policy_key` using `dbt_utils.relationships(field='sb_policy_key', to=ref('stg__decfile__sb_policy_lookup'))`.
        *   `policy_chain_id`: Test `not_null`. Test relationship to `stg__modcom__policy_chain_v3.policy_chain_id`.
        *   `associated_policy_key` (generated by `policy_key()` macro): Test `not_null`. Its components (`company_numb`, `policy_sym`, etc.) must be `not_null`.
        *   Verify that all `sb_policy_key` from `stg__decfile__sb_policy_lookup` that have a `policy_chain_id` are present (covered by `assert_lkp_associated_policies_coverage.sql` - review and enhance if needed).
        *   Verify that all `policy_chain_id` in this lookup exist in `stg__modcom__policy_chain_v3` (also covered by `assert_lkp_associated_policies_coverage.sql`).
    *   **Join Logic**:
        *   The inner join `on sb.policy_chain_id = pc.policy_chain_id` is critical. Test for scenarios where a `sb_policy_key` might be dropped if its `policy_chain_id` is not in `policy_chain_source`.
        *   The `where` clauses in CTEs (e.g., `is not null` checks) are vital. Test their impact.

2.  **`lkp__billing_policies.sql`**
    *   **AIV Field Alignment**: `policy_eff_date` is used. Ensure its accuracy.
    *   **Key Integrity**:
        *   `billing_sb_policy_key`: Test `not_null`, `unique` (as it's generated by `row_number()`).
        *   `associated_policy_key`, `associated_sb_policy_key`: Test `not_null`. Test relationships to `lkp__associated_policies`.
        *   `billing_acct_key`, `billing_policy_key`: Test `not_null`.
    *   **Join Logic**: The `left join associated_policies` and subsequent `where associated_policies.associated_policy_key is not null` effectively acts as an inner join. Verify this doesn't unintentionally drop records from `raw_billing_pols`.
        *   Check row counts before and after the join/filter.

3.  **`lkp__dates.sql`**
    *   **Date Logic**: Verify the correctness of `prior_year_start` and `prior_year_end` calculations for all `n_prior_years`.
    *   Test for `not_null` on all output columns.
    *   Ensure `input_date` correctly sources from `lkp__sb_policy_key`.

4.  **`lkp__first_billing_activity_date.sql`**
    *   **Key Integrity**: `activity_trans_key` should be `not_null` and exist in `fct__billing_activity`.
    *   **Logic**: Verify `min(billing_activity_date)` correctly identifies the first date.

5.  **`lkp__policy_chain_ids.sql`**
    *   **Key Integrity**: `policy_chain_id` should be `not_null` and exist in `stg__decfile__sb_policy_lookup` and `stg__modcom__policy_chain_v3`.
    *   **Aggregation Logic**: Verify `n_sb_policies_for_policy_chain_id` and `n_total_policies_for_policy_chain_id` counts are correct.

### Phase 4: Fact Layer (`models/03_fct/`)

**Objective**: Verify calculations, joins, and key generation in fact tables. This is where core measures like billing amounts are handled.

1.  **`fct__billing_activity.sql` (Critical for Aggregates)**
    *   **AIV Field Impact**: If `billing_activity_date` or policy keys are linked to AIV validity periods, ensure this is handled.
    *   **Key Integrity**:
        *   `activity_trans_key`: Test `not_null`, `unique`.
        *   `associated_policy_key`, `associated_sb_policy_key`: Test `not_null`. Test relationships to `lkp__associated_policies`.
    *   **Aggregate Premium/Loss Checks**:
        *   `billing_activity_amt`: This is a primary monetary field.
            *   Test for `not_null` if applicable.
            *   Profile its distribution (`dbt_profiler`). Check for extreme values or unexpected negatives/positives.
            *   **Reconcile Sums**: Sum `billing_activity_amt` and compare against totals from `stg__cur_cb` (considering any transformations or filters). This is a key reconciliation point.

2.  **`fct__associated_policy_eff_date.sql`**
    *   **Key Integrity**:
        *   `associated_policy_key`: Test `not_null`. Test relationship to `lkp__associated_policies`.
    *   **Join Logic**: The `left join dates` and `where dates.policy_eff_date is not null` (effectively an inner join) should be checked for unintended record loss.
    *   **Date Logic**: Ensure correct mapping of `policy_eff_date` to `prior_year_start/end` from `lkp__dates`.

3.  **`fct__prior_activity_dates.sql`**
    *   **Key Integrity**: `activity_trans_key` should be `not_null` and exist in `fct__billing_activity`.
    *   **Join Logic**: Ensure the join to `fct__associated_policy_eff_date` is correct.
    *   **Filtering Logic**: The `where policy_eff_date < billing_activity_date` is critical. Test this logic thoroughly.
    *   **Macro Usage**: The `make_n_prior_year_cols` macro's output needs to be validated here. Check that the pivoted date columns are populated correctly.

### Phase 5: Mart Layer (`models/05_mrt/`)

**Objective**: Ensure final aggregations and data presentation in marts are accurate and ready for consumption.

1.  **`dm__npc_counts.sql` (Critical for Aggregates)**
    *   **AIV Field Impact**: `policy_eff_date` is used. If AIV data influences which policies are active or how NPC is calculated, ensure this is reflected.
    *   **Key Integrity**:
        *   `sb_policy_key`: Test `not_null`. Test relationship to `lkp__associated_policies.associated_sb_policy_key` (covered by `assert_dm_npc_counts_referential_integrity.sql` - review).
        *   `policy_chain_id`: Ensure consistency.
    *   **Aggregate Premium/Loss Checks (Final Reconciliation)**:
        *   `prior_yrX_c_activity_amount_sum`: These are key output measures.
            *   Test for `not_null` (should be 0 if no activity, due to `coalesce`).
            *   Verify the calculation logic:
                *   The `case when date_part('year', p.policy_eff_date) - date_part('year', b.billing_activity_date) = X then ... end as nth_prior_year` logic is complex and needs careful testing. Ensure correct assignment of activity to prior years.
                *   The condition `b.billing_activity_date < p.policy_eff_date` is crucial.
            *   **Reconcile Sums**: The sums in this mart must be reconcilable back to `fct__billing_activity.billing_activity_amt` by applying the same filtering and grouping logic. This is a major validation point.
            *   Use `dbt_profiler` to check the distribution of these summed amounts.
    *   **Join Logic**: The `left join aggregated_prior_c_by_year` ensures all policies from `policy_info` are kept. Verify this.

### Phase 6: Check Layer (`models/06_chk/`)

**Objective**: These models perform meta-checks, often for row count validation during complex transformations.

1.  **`chk__lkp__associated_policies__row_counts.sql`**
    *   **Purpose**: This model is designed to track row counts through the CTEs used to build `lkp__associated_policies`.
    *   **Action**: Review the logic of this check model itself to ensure it accurately reflects the row counts at each step of `lkp__associated_policies`. The final output `cte, row_count` should be monitored. Any unexpected drops in `row_count` between steps indicate potential issues in `lkp__associated_policies` logic (e.g., joins dropping more rows than expected).

## 5. Ongoing Monitoring and Test Enhancement

*   **Regular Execution**: Run `dbt test` as part of every dbt execution cycle, especially before deploying changes.
*   **Review Test Results**: Actively monitor and investigate any test failures.
*   **Data Profiling**: Periodically run `dbt_profiler` (or `dbt_eda_tools`) on key final models (e.g., `dm__npc_counts`, `fct__billing_activity`) to detect:
    *   Data drift (changes in distributions, null rates over time).
    *   New outliers or unexpected values.
*   **`testgen` for New Tests**: Use `testgen` to scan data and suggest new `not_null`, `unique`, or `accepted_values` tests, especially after significant data updates or additions.
*   **Refine Custom Tests**: Continuously review and improve custom singular and generic tests based on new insights or business rule changes.
*   **Source Data Changes**: If upstream source data schemas or contents change, revisit and update relevant tests, especially AIV and aggregate checks.

This data testing plan provides a comprehensive framework. It should be treated as a living document and updated as the dbt project evolves.
