# Analysis and Update Strategy for dm__npc_counts Model

## 0. Preamble: SAS Macro Context
This analysis has been updated after reviewing a legacy SAS macro (`%make_prior_year_cols`) and its attempted dbt equivalent (`make_n_prior_year_cols`). The SAS macro is considered the definitive source for the historical business logic regarding "prior year" calculations, and the dbt implementation must align with it. This context is crucial for understanding historical definitions and ensuring the correct business logic is implemented.

## 1. Background and Objective

The `dm__npc_counts` model is a critical component in the underwriting process. Its primary objective is to provide features for an analytical model that assesses risk associated with insurance policies. Specifically, it aims to calculate the total number of non-payment cancellation (NPC) events for each `sb_policy_key` within the one, two, three, four, and five years immediately preceding the policy's effective date (renewal).

These counts serve as a proxy for an insured's propensity to default on premium payments, influencing underwriting decisions, risk assessment, and the amount of credit offered to retain an account.

Currently, the model faces challenges related to performance (it runs too slowly) and uncertainty regarding the correctness of its output. This document outlines a comprehensive review and a strategy for addressing these issues.

### 1.1. Legacy SAS Macro Context (`%make_prior_year_cols`)

The SAS macro `%make_prior_year_cols` is the **authoritative source** for the business logic defining prior year calculations. Its parameters and logic must be accurately replicated in the dbt implementation.

**Key Parameters (SAS):**
*   `data`: Input dataset.
*   `relative_date`: The reference date (e.g., `policy_eff_date`).
*   `compare_date`: The event date to categorize (e.g., `billing_activity_date`).
*   `n_prior_years`: Number of prior year windows (default: 5).
*   `n_month_lag`: Lag in months (default: 4) to define an `eval_date`.

**Core SAS Logic to be Replicated:**
1.  **`eval_date` Calculation:** `eval_date = intnx('month', &relative_date., -&n_month_lag., 's')`. This date is `n_month_lag` months prior to `relative_date` (same day of the month).
2.  **Prior Year Window Definitions (`yrX_prior_date`):**
    *   `yr1_prior_date = intnx('month', &relative_date., -12, 's')`
    *   `yr2_prior_date = intnx('month', &relative_date., -24, 's')`
    *   ...and so on for `n_prior_years`. These define the *end date* of each 12-month block looking backward from `relative_date`.
3.  **Slotting Transactions (`nth_prior_year`):**
    *   **Lag Handling (Crucial):** If `compare_date > eval_date`, then `nth_prior_year = 0`. Events within the `n_month_lag` period before `relative_date` are assigned to year 0.
    *   **Prior Year Bucketing:** Otherwise (if `compare_date <= eval_date`):
        *   1st prior year (`nth_prior_year = 1`): `compare_date <= yr1_prior_date` AND `compare_date > yr2_prior_date`. This corresponds to the interval `(relative_date - 24 months, relative_date - 12 months]`.
        *   i-th prior year (`nth_prior_year = i`): `compare_date <= yr(i)_prior_date` AND `compare_date > yr(i+1)_prior_date`. This corresponds to `(relative_date - (i+1)*12 months, relative_date - i*12 months]`.
    *   Events older than the defined windows are assigned `nth_prior_year = 9999`.

This precise logic, especially the `n_month_lag` creating `nth_prior_year = 0` and the specific 12-month window definitions, must be the target for the dbt implementation.

### 1.2. Analysis of `make_n_prior_year_cols` dbt Macro (Deviations from SAS Logic)

The dbt macro `make_n_prior_year_cols` (in `bop_modeling_data/macros/make_n_prior_year_cols.sql`) is an attempt to translate the SAS logic but currently **deviates significantly** and must be corrected to align with the SAS business rules.

**Key Parameters (dbt):** Similar to SAS.

**Core Logic & Deviations from SAS:**
1.  **`eval_date` Calculation (`_build_eval_date`):**
    *   Calculates `eval_date` as `relative_date - interval n_months months`. This part is conceptually aligned with SAS.
2.  **Prior Year Window Definitions (`_build_prior_year_cols`, `yrX_prior_date`):**
    *   dbt macro: `yr1_prior_date` is `relative_date - interval 0 years` (i.e., `relative_date`).
    *   dbt macro: `yr(i)_prior_date` is `relative_date - interval (i-1) years`.
    *   **Deviation from SAS:** This is incorrect. SAS `yr1_prior_date` is `relative_date - 12 months`. The dbt macro's `yrX_prior_date` definitions are shifted relative to SAS, leading to different time windows. SAS `yr(i)_prior_date` is `relative_date - (i*12) months`.
3.  **Slotting Transactions (`_slot_transactions_into_prior_years`):**
    *   The dbt macro uses a `CASE` statement:
        *   1st prior year (slot `1`): `compare_date <= yr1_prior_date` (i.e., `relative_date`) AND `compare_date > yr2_prior_date` (i.e., `relative_date - 1 year`). This defines the period `(relative_date - 1 year, relative_date]`.
    *   **Critical Deviation from SAS (Lag Handling):** The dbt macro **fails to implement the SAS logic for `eval_date`**. It does not assign `prior_year = 0` for events occurring after `eval_date` (within the `n_month_lag`). This is a major functional gap.
    *   **Critical Deviation from SAS (Window Definitions):** Due to the incorrect `yrX_prior_date` definitions, the actual time windows for `prior_year = 1, 2, ...` in the dbt macro do not match the SAS-defined windows. For example:
        *   SAS 1st prior year: `(relative_date - 24 months, relative_date - 12 months]`
        *   Current dbt 1st prior year: `(relative_date - 1 year, relative_date]` (This is more recent and a different 12-month block).
    *   Events older than the defined windows are assigned `9999` (consistent with SAS for out-of-range).

The dbt macro `make_n_prior_year_cols` **requires significant correction** to align with the authoritative SAS logic, particularly in its window boundary definitions and the handling of the `n_month_lag` to assign `prior_year = 0`.

### 1.3. Implications for `dm__npc_counts` and Strategy Update (SAS Alignment Focus)

The analysis of the SAS macro (the source of truth) and the current dbt macro (requiring correction) dictates the following:

1.  **SAS Definition of "Prior Year" is Non-Negotiable:** The `dm__npc_counts` model must use the SAS definition. The current `date_part` logic in `dm__npc_counts` is incorrect and must be replaced.
2.  **The `n_month_lag` is a Core Requirement:** The SAS logic of using an `n_month_lag` to create an `eval_date` and assign `nth_prior_year = 0` to recent activities is a confirmed business rule that must be implemented.
3.  **Correcting or Replacing `make_n_prior_year_cols`:**
    *   The dbt macro `make_n_prior_year_cols` must be **fixed** to accurately reflect the SAS logic for `yrX_prior_date` boundaries and, crucially, to incorporate the `eval_date` logic for assigning `prior_year = 0`.
    *   If correcting the macro is not feasible, custom SQL within `dm__npc_counts` must be written to achieve the SAS-defined outcome.

**Updated Strategic Direction (SAS Alignment):**
*   **Priority 1:** Implement the SAS-defined "prior year" logic, including the `n_month_lag` and its `prior_year = 0` assignment, and the precise window boundaries.
*   **Priority 2:** Modify the `make_n_prior_year_cols` dbt macro to be SAS-compliant or develop SAS-compliant custom logic within `dm__npc_counts`.
*   **Priority 3:** Rigorously test the implementation against the SAS logic, especially for boundary conditions, the lag period, and `prior_year = 0` assignment.

This new context, with SAS as the definitive source, heavily influences the "Implement Core SAS-Defined Requirements" and "Modify `dm__npc_counts` Model Logic to Align with SAS" sections of the roadmap.

## 2. Data Pipeline Overview

The `dm__npc_counts` model sits at the end of a data transformation pipeline. Its direct upstream dependencies are `fct__billing_activity` and `lkp__associated_policies`.

```
[Source Systems]
      |
      v
--------------------------------------
| Staging Models                     |
| - stg__cur_cb (Billing Data)       |
| - stg__decfile__sb_policy_lookup   |
| - stg__modcom__policy_chain_v3     |
--------------------------------------
      |        |            |
      |        +-----+------+
      |              |
      v              v
--------------------------------------      --------------------------------------
| Intermediate Models                |      | Lookup Models                      |
| - fct__billing_activity            |----->| - lkp__associated_policies         |
--------------------------------------      --------------------------------------
                   |                                      |
                   +-----------------+--------------------+
                                     |
                                     v
                             --------------------
                             | dm__npc_counts   |
                             --------------------
```

### 2.1. `lkp__associated_policies`

*   **File:** `bop_modeling_data/models/02_lkp/lkp__associated_policies.sql`
*   **Purpose:** This model links small business policy keys (`sb_policy_key`) to their broader policy chain information, including all associated policy keys within that chain and their respective effective dates.
*   **Implementation Details:**
    *   Materialized as a `table`.
    *   Defines a `unique_key` on `['associated_policy_key', 'associated_sb_policy_key']`.
    *   **Sources:**
        *   `stg__decfile__sb_policy_lookup`: Provides `sb_policy_key` and `policy_chain_id`. Filters out null keys.
        *   `stg__modcom__policy_chain_v3`: Provides detailed policy attributes (`company_numb`, `policy_sym`, `policy_numb`, `policy_module`, `policy_eff_date`) based on `policy_chain_id`. Filters out null key components.
    *   **Logic:**
        1.  Joins `sb_policies_source` (from `stg__decfile__sb_policy_lookup`) with `policy_chain_source` (from `stg__modcom__policy_chain_v3`) on `policy_chain_id`. This links each `sb_policy_key` to all policies in its chain.
        2.  Generates `associated_policy_key` using the `policy_key()` macro (the exact logic of this macro is external to this model's SQL but crucial).
        3.  Outputs `associated_policy_key`, `associated_sb_policy_key`, `policy_chain_id`, the five policy key components, and `policy_eff_date`.
*   **Data Testing:**
    *   Includes a `unique_key` test.
    *   Further specific logic tests are not detailed in the provided file but would be beneficial (e.g., referential integrity to sources, format of `policy_key()`).

### 2.2. `fct__billing_activity`

*   **File:** `bop_modeling_data/models/03_fct/fct__billing_activity.sql`
*   **Purpose:** This model prepares billing activity data, creating a unique key for each transaction.
*   **Implementation Details:**
    *   **Sources:**
        *   `stg__cur_cb` (presumably raw billing transactions).
        *   `lkp__dates` (likely a date dimension table, though not used in the provided snippet's final select).
    *   **Logic:**
        1.  Creates `activity_trans_key` by generating an MD5 hash of various billing and policy keys, and date components (`billing_acct_key`, `year/month/day of billing_activity_date`, `billing_sb_policy_key`, `associated_policy_key`, `associated_sb_policy_key`, `billing_policy_key`).
        2.  Selects `activity_trans_key`, `associated_policy_key`, `associated_sb_policy_key`, `billing_activity_date`, and `billing_activity_amt`.
    *   **Output Grain:** One row per billing activity, identified by `activity_trans_key`.
*   **Data Testing:**
    *   Specific tests are not detailed in the file. Tests for uniqueness of `activity_trans_key`, referential integrity, and the presence of an activity type indicator (see Section 4.2.1) would be crucial.

### 2.3. Current State of General Data Testing

*   The workspace includes a `CHECKING.md` file with general guidelines, such as checking key integrity and consistency with AIV values.
*   A `bop_modeling_data/tests/` directory exists, suggesting some dbt tests are implemented.
*   However, the specifics of tests applied to the direct upstream models of `dm__npc_counts` are not available in the provided context, beyond the `unique_key` in `lkp__associated_policies`. A thorough review of existing tests and the implementation of new, targeted tests is a key part of the proposed strategy.

## 3. `dm__npc_counts` - Current Implementation

*   **File:** `bop_modeling_data/models/05_mrt/dm__npc_counts.sql`
*   **Purpose:** To calculate, for each policy, the count and sum of billing activities in each of the 5 years prior to its effective date.
*   **Materialization:** `table`

### CTE Breakdown:

1.  **`billing_activity`**:
    *   Selects `sb_policy_key`, `billing_activity_date`, and `billing_activity_amt` (renamed to `billing_activity_amount`) from `ref('fct__billing_activity')`.
    *   **Critically, this CTE does not filter for "non-payment cancellation" events specifically. It ingests all billing activities.**

2.  **`policy_info`**:
    *   Selects distinct `associated_sb_policy_key` (as `sb_policy_key`), `policy_chain_id`, and `policy_eff_date` from `ref('lkp__associated_policies')`.
    *   This CTE establishes the base grain: one row per unique policy term identified by `sb_policy_key` and its `policy_eff_date`.

3.  **`prior_year_activities`**:
    *   Joins `policy_info` (aliased `p`) with `billing_activity` (aliased `b`) on `p.sb_policy_key = b.sb_policy_key`.
    *   Calculates `nth_prior_year` as the difference in calendar years: `date_part('year', p.policy_eff_date) - date_part('year', b.billing_activity_date)`.
        *   This calculation only occurs if `b.billing_activity_date < p.policy_eff_date`. Otherwise, `nth_prior_year` is `null`.
    *   **Filters:**
        *   `b.billing_activity_date < p.policy_eff_date`: Ensures only activities *before* the policy effective date are considered.
        *   The year difference (`date_part('year', p.policy_eff_date) - date_part('year', b.billing_activity_date)`) must be between 1 and 5 (inclusive). This limits the lookback period.

4.  **`aggregated_prior_c_by_year`**:
    *   Aggregates data from `prior_year_activities`.
    *   Groups by `sb_policy_key` and `nth_prior_year`.
    *   Calculates:
        *   `COUNT(*) as c_activity_count`
        *   `SUM(billing_activity_amount) as c_activity_amount_sum`
    *   Filters out rows where `nth_prior_year IS NULL` (this filter is likely redundant given prior logic).

5.  **`final`**:
    *   Pivots the results from `aggregated_prior_c_by_year` to create separate columns for each of the 5 prior years.
    *   Starts with `policy_info` as the base (`p`) to ensure all policies are included in the output.
    *   Left joins `aggregated_prior_c_by_year` (`agg`) on `p.sb_policy_key = agg.sb_policy_key`.
    *   Uses conditional aggregation (`SUM(CASE WHEN agg.nth_prior_year = X THEN ... ELSE 0 END)`) for each year (1 through 5) to get `prior_yrX_c_activity_count` and `prior_yrX_c_activity_amount_sum`.
    *   `COALESCE` is used to default these counts/sums to 0 if no activity is found for a given year.
    *   Groups by `p.sb_policy_key`, `p.policy_chain_id`, `p.policy_eff_date`.

6.  **Final Select**: `SELECT * FROM final`.

## 4. Potential Inefficiencies and Unexpected Results

### 4.1. Inefficiencies

1.  **Broad Join in `prior_year_activities`**: The join between `policy_info` and `billing_activity` occurs on `sb_policy_key` before date-based filtering effectively reduces the `billing_activity` side for each policy. If `fct__billing_activity` is large and there are many activities per `sb_policy_key`, this join can be resource-intensive.
2.  **Repeated Date Part Calculation**: `date_part('year', p.policy_eff_date) - date_part('year', b.billing_activity_date)` is computed in the `SELECT` and then implicitly re-evaluated or used in the `WHERE` clause of `prior_year_activities`. While modern query planners might optimize this, it's less explicit.
3.  **Pivot Implementation**: The `SUM(CASE ...)` pattern for pivoting is standard but can lead to multiple scans or complex processing over the `aggregated_prior_c_by_year` CTE, depending on the database optimizer.
4.  **Redundant Filter**: The `WHERE nth_prior_year IS NOT NULL` in `aggregated_prior_c_by_year` is likely redundant due to the conditions in `prior_year_activities` (`b.billing_activity_date < p.policy_eff_date` and the year difference filter).

### 4.2. Unexpected Results / Risks / Ambiguities

1.  **CRITICAL - Misinterpretation of "Non-Payment Cancellation Event"**:
    *   The model currently counts **all** billing activities from `fct__billing_activity` and sums their amounts. The stated requirement is for "non-payment cancellation events".
    *   `fct__billing_activity` (as per its SQL) does not show any explicit filtering for NPC event types. If `stg__cur_cb` contains various types of billing activities (e.g., payments, endorsements, cancellations for various reasons), the current model output is **not** specific to NPCs and therefore does not meet the primary business requirement.
2.  **Relevance of `_amount_sum` Columns**: The primary goal is the *count* of NPCs. The summation of `billing_activity_amount` might be irrelevant or secondary. If these sums are not needed, removing them would simplify the model.
3.  **Definition of "Prior Year"**:
    *   The current logic `date_part('year', p.policy_eff_date) - date_part('year', b.billing_activity_date)` uses calendar year differences.
        *   Example: Activity on `2022-12-31` for a policy effective `2023-01-01` is "1st prior year".
        *   Example: Activity on `2023-01-02` for a policy effective `2023-12-31` is *not* considered a prior year activity by this logic.
    *   This may or may not align with the business understanding of "within the one...five years prior to renewal," which could imply full 365-day periods. This needs clarification. The `make_n_prior_year_cols.sql` macro in the workspace uses interval-based logic (e.g., `date - interval N months/years`) which offers more precision if needed.
4.  **Data Skew**: If certain `sb_policy_key`s have an exceptionally high volume of billing activities, they could cause performance bottlenecks during joins and aggregations.
5.  **Upstream Data Integrity**:
    *   The correctness of the `policy_key()` macro used in `lkp__associated_policies` is vital. Any errors there would propagate.
    *   The completeness and accuracy of `fct__billing_activity`, particularly regarding the consistent recording of all relevant activities and their dates, are paramount.
6.  **Timezone Consistency**: All date operations assume consistent timezone handling in the source data. Discrepancies could lead to incorrect `nth_prior_year` calculations.

## 5. Strategy for Mitigation and Improvement

### 5.1. Addressing the Core Requirement (NPC Events)

1.  **Investigate Billing Data Source (`stg__cur_cb`)**:
    *   **Action**: Analyze `stg__cur_cb` (the source of `fct__billing_activity`) to identify a column or combination of columns that reliably indicates a "non-payment cancellation" event. This might be an event type code, a transaction description, or a status flag.
    *   **If Found**: Modify the `billing_activity` CTE in `dm__npc_counts.sql` (or preferably, enhance `fct__billing_activity` itself) to include and filter by this NPC indicator.
        ```sql
        -- Example modification in dm__npc_counts.sql's billing_activity CTE
        WITH billing_activity AS (
            SELECT
                sb_policy_key,
                billing_activity_date,
                billing_activity_amt AS billing_activity_amount
                -- , billing_event_type -- Assuming this column exists
            FROM {{ ref('fct__billing_activity') }}
            WHERE billing_event_type = 'NPC' -- Or appropriate filter condition
        ),
        ```
    *   **If Not Found**: This is a critical data gap. A project to identify and capture this information at the source or in staging will be necessary. Without it, `dm__npc_counts` cannot meet its stated goal.
2.  **Clarify Need for `_amount_sum`**:
    *   **Action**: Confirm with stakeholders if the sum of billing amounts for NPCs is required.
    *   **If Not**: Remove the `_amount_sum` calculations from `aggregated_prior_c_by_year` and `final` CTEs to simplify logic and potentially improve performance.

### 5.2. Enhancing Performance

1.  **Filter Early**: If the NPC filter is applied in the `billing_activity` CTE (or upstream in `fct__billing_activity`), this will significantly reduce the number of rows processed in subsequent joins and aggregations.
2.  **Optimize `nth_prior_year` Calculation and Join**:
    *   Consider calculating year components or the year difference directly on `fct__billing_activity` if it's beneficial for indexing or partitioning (if applicable in DuckDB for the dataset size).
    *   Ensure `sb_policy_key` is efficiently indexed or that data is organized to benefit joins in DuckDB for both `lkp__associated_policies` and `fct__billing_activity`.
    *   The `billing_activity_date` in `fct__billing_activity` and `policy_eff_date` in `lkp__associated_policies` should also be suitable for efficient range filtering.
3.  **Refine "Prior Year" Definition (if necessary)**:
    *   **Action**: Confirm the definition of "N years prior" with stakeholders.
    *   **If Calendar Year Difference is Correct**: The current logic is fine, but ensure it's documented.
    *   **If Full Year Periods are Needed**: Adapt logic using date interval functions. The `make_n_prior_year_cols.sql` macro provides examples:
        ```sql
        -- Conceptual: for 1st prior year
        -- b.billing_activity_date >= date_sub(p.policy_eff_date, interval 1 year) AND
        -- b.billing_activity_date < p.policy_eff_date
        ```
        This would require restructuring the `nth_prior_year` calculation and potentially the pivoting logic. One approach is to calculate date boundaries for each prior year relative to `policy_eff_date` and then check if `billing_activity_date` falls within those boundaries.

4.  **Incremental Materialization (Long-term)**: If `dm__npc_counts` or its large upstream fact tables are full-scanned frequently, explore incremental materialization strategies based on `policy_eff_date` or transaction dates to process only new/updated data.

### 5.3. Improving Clarity and Reducing Redundancy

1.  **Remove Redundant Filter**: Remove `WHERE nth_prior_year IS NOT NULL` from `aggregated_prior_c_by_year`.
2.  **Documentation**: Add detailed comments within the SQL code explaining each CTE's purpose and any complex logic, especially the "prior year" calculation.

## 6. Strategy for Ensuring Data Accuracy and Reasonability

A multi-layered testing approach is essential:

### 6.1. Upstream Model Testing

*   **`fct__billing_activity`**:
    *   **Uniqueness & Non-Null**: `activity_trans_key` (if intended as PK), `sb_policy_key`, `billing_activity_date`.
    *   **Referential Integrity**: `sb_policy_key` to `lkp__associated_policies`.
    *   **Value Tests**: If an NPC indicator column is identified (e.g., `billing_event_type`), test for expected values and distribution. `dbt_expectations.expect_column_values_to_be_in_set`.
    *   **Range Checks**: `billing_activity_date` (should be reasonable, not in the future), `billing_activity_amt` (e.g., not excessively large or negative if inappropriate).
*   **`lkp__associated_policies`**:
    *   **Uniqueness**: `(associated_policy_key, associated_sb_policy_key)` (already configured). Add test for `(associated_sb_policy_key, policy_eff_date)` if this should be unique for the purpose of `dm__npc_counts`.
    *   **Non-Null**: All components of the five-key, `policy_chain_id`, `policy_eff_date`.
    *   **Referential Integrity**: `policy_chain_id` to its source (`stg__modcom__policy_chain_v3`).
    *   **Custom Tests**: Validate the output of the `policy_key()` macro if possible (e.g., format, non-null).

### 6.2. `dm__npc_counts` Specific Logic Tests

Implement singular tests (e.g., using `dbt_utils.test_expression` or custom data tests) for various scenarios:

1.  **No Prior NPC Activity**: Policy with no NPC events before `policy_eff_date`. Expected: All `prior_yrX_c_activity_count` are 0.
2.  **NPC Activity in Specific Prior Year**: Policy with one NPC event X months/days into a specific prior year window. Expected: Correct `prior_yrN_c_activity_count = 1`, others 0.
3.  **NPC Activity Spanning Multiple Prior Years**: Policy with NPC events in years 1, 3, and 5 prior. Expected: Correct counts for these years, 0 for others.
4.  **NPC Activity Outside 5-Year Lookback**: Policy with NPC event 6 years prior. Expected: All `prior_yrX_c_activity_count` are 0.
5.  **NPC Activity On or After Policy Effective Date**: Policy with NPC event on `policy_eff_date` or after. Expected: Not counted in any prior year.
6.  **Boundary Condition Tests for Year Calculation**:
    *   Activity: `YYYY-12-31`, Policy Eff: `(YYYY+1)-01-01`. Expected: Counted in `prior_yr1_c_activity_count`.
    *   Activity: `YYYY-01-01`, Policy Eff: `YYYY-12-31`. Expected: Not counted as prior year activity. (Confirm this behavior aligns with the chosen "prior year" definition).
7.  **Key Integrity**: Ensure all `sb_policy_key` from `policy_info` are present in the final output.
8.  **Non-Negative Counts**: All `prior_yrX_c_activity_count` columns should be >= 0 (guaranteed by `COALESCE(..., 0)` but good to assert).

### 6.3. Aggregate Reasonableness and Monitoring

*   **Row Count Preservation**: Check that the number of unique `(sb_policy_key, policy_eff_date)` combinations in `dm__npc_counts` matches that in the `policy_info` CTE.
*   **Distribution Checks**: Monitor the distribution of `prior_yrX_c_activity_count` values. Are they within expected ranges? Are there extreme outliers? `dbt_expectations` can help here.
*   **Trend Analysis**: Track key metrics (e.g., average prior year NPC counts, percentage of policies with >0 prior NPCs) over time to detect anomalies or shifts in data patterns.
*   **Model Run Time and Test Success**: Monitor dbt run times and ensure all tests pass consistently. Set up alerts for failures.

### 6.4. Documentation and Review

*   **dbt Docs**: Maintain comprehensive documentation for all involved models and columns using `dbt docs generate`. Clearly explain the logic for `nth_prior_year` and the definition of an NPC event.
*   **Code Reviews**: Institute peer reviews for all changes to these critical models.
*   **Stakeholder Validation**: Regularly review the logic and outputs with business stakeholders to ensure continued alignment with requirements.

By systematically addressing the identified issues, particularly the definition and filtering of NPC events, and by implementing a robust testing and monitoring strategy, the `dm__npc_counts` model can be transformed into a reliable and performant asset for the underwriting process.

# Roadmap to Production-Grade dm__npc_counts Model

This checklist outlines the key steps to transform the `dm__npc_counts` model into a robust, reliable, and performant production-grade asset, ensuring alignment with established SAS business logic.

1.  **[ ] Implement Core SAS-Defined Requirements:**
    *   **[ ] Define "Non-Payment Cancellation (NPC) Event":**
        *   **[ ] Action:** Investigate `stg__cur_cb` (source of `fct__billing_activity`) to identify the exact column(s) and value(s) that signify an NPC event.
        *   **[ ] Stakeholder Confirmation:** Validate this definition with business stakeholders.
    *   **[ ] Implement SAS "Prior Year" Definition (Crucial Update):**
        *   **[ ] Action:** The SAS macro (`%make_prior_year_cols`) dictates the definition of "N years prior." Key aspects to implement precisely:
            *   **`n_month_lag`:** The SAS macro uses an `n_month_lag` (default 4 months) to create an `eval_date`. Activities occurring *after* this `eval_date` (i.e., within the `n_month_lag` period immediately preceding `policy_eff_date`) **must** be assigned `nth_prior_year = 0`. This is a confirmed business requirement from the SAS logic.
            *   **Lookback Period & Boundary Definitions:** Implement the exact 12-month interval definitions for each prior year window as per the SAS macro's `yrX_prior_date` calculations and its slotting logic (e.g., 1st prior year being `(policy_eff_date - 24m, policy_eff_date - 12m]`).
        *   **[ ] Document:** Clearly document how the SAS logic (including the lag and boundary definitions) is implemented in the dbt model.
    *   **[ ] Validate Need for `_amount_sum` Columns:**
        *   **[ ] Action:** Confirm with stakeholders if the sum of billing amounts for NPCs is a required output (this is separate from the prior year logic).

2.  **[ ] Refine Upstream Models:**
    *   **[ ] `fct__billing_activity`:**
        *   **[ ] Action (If NPC identified):** Modify `fct__billing_activity` to include the NPC indicator and, if appropriate, filter for NPC events or clearly flag them. This is preferable to filtering only in `dm__npc_counts`.
        *   **[ ] Action (Data Gap):** If NPC event data is missing, initiate a process to capture this information in source systems or staging.
    *   **[ ] `lkp__associated_policies`:**
        *   **[ ] Action:** Review and validate the logic of the `policy_key()` macro.

3.  **[ ] Modify `dm__npc_counts` Model Logic to Align with SAS:**
    *   **[ ] Action:** Implement the confirmed NPC event filter (ideally by leveraging changes in `fct__billing_activity`).
    *   **[ ] Action (Decision Point & Implementation - SAS Alignment is Key):**
        *   **Option A (Correct and Use `make_n_prior_year_cols` Macro):** Modify the existing `make_n_prior_year_cols` dbt macro to **exactly replicate the SAS macro's logic**. This includes:
            *   Correcting the `yrX_prior_date` boundary definitions.
            *   Implementing the `eval_date` logic to assign `prior_year = 0` for events within the `n_month_lag` period.
        *   **Option B (Custom Logic - SAS-Compliant):** If refactoring the dbt macro proves too complex, implement custom SQL directly within `dm__npc_counts` that precisely mirrors the SAS macro's calculation for `nth_prior_year`, including the lag and window definitions.
    *   **[ ] Action:** Ensure the `prior_year = 0` assignment for the lag period, as per SAS logic, is correctly implemented and tested.
    *   **[ ] Action:** Remove `_amount_sum` calculations if deemed unnecessary.
    *   **[ ] Action:** Remove redundant filter: `WHERE nth_prior_year IS NOT NULL` in `aggregated_prior_c_by_year` (if this CTE structure is maintained).

4.  **[ ] Implement Comprehensive Data Testing (using `dbt-expectations` and custom tests):**
    *   **[ ] `stg__cur_cb` (or earliest point of billing data):**
        *   **[ ] Tests:** Add tests for freshness, NPC indicator presence and expected values, key non-nullability.
    *   **[ ] `fct__billing_activity`:**
        *   **[ ] Tests:** Uniqueness (`activity_trans_key`), non-nulls (`sb_policy_key`, `billing_activity_date`, NPC indicator), referential integrity (`sb_policy_key` to `lkp__associated_policies`), value sets for NPC indicator, date ranges, amount ranges. (See Section 7 for `dbt-expectations` examples).
    *   **[ ] `lkp__associated_policies`:**
        *   **[ ] Tests:** Uniqueness (`(associated_policy_key, associated_sb_policy_key)`, `(associated_sb_policy_key, policy_eff_date)`), non-nulls (key components, `policy_chain_id`, `policy_eff_date`), referential integrity (`policy_chain_id`), `policy_key()` output format.
    *   **[ ] `dm__npc_counts`:**
        *   **[ ] Logic Tests (Singular - SAS Alignment):** Cover scenarios outlined in Section 6.2, ensuring they validate against the SAS-defined prior year logic (including `prior_year = 0` for the lag period, and correct window boundaries).
        *   **[ ] Aggregate/Distribution Tests:** Row count preservation, non-negative counts, distribution of `prior_yrX_c_activity_count` values (e.g., mean, median, max within expected bounds). (See Section 7).
        *   **[ ] Key Integrity:** All `sb_policy_key` from `policy_info` are present.

5.  **[ ] Optimize Performance:**
    *   **[ ] Action:** Ensure NPC filtering occurs as early as possible in the pipeline.
    *   **[ ] Action:** Review DuckDB query plans for joins and aggregations; consider indexing or data organization if beneficial.
    *   **[ ] Action (Long-term):** Evaluate incremental materialization for `dm__npc_counts` and its large upstream dependencies.

6.  **[ ] Enhance Documentation and Review Processes:**
    *   **[ ] Action:** Update dbt model descriptions and column comments for all affected models, explicitly referencing SAS logic for prior year calculations.
    *   **[ ] Action:** Ensure `dm__npc_counts__update.md` is kept current.
    *   **[ ] Action:** Implement mandatory code reviews for changes to these models.
    *   **[ ] Action:** Schedule regular reviews of logic and output with stakeholders, confirming continued alignment with the (SAS-derived) business requirements.

7.  **[ ] Monitoring and Maintenance:**
    *   **[ ] Action:** Set up dbt test alerts.
    *   **[ ] Action:** Monitor model run times.
    *   **[ ] Action:** Periodically review data distributions and trends.

## 7. Leveraging `dbt-expectations` for Enhanced Data Believability

The `dbt-expectations` package (v0.10.4 is installed) provides a powerful suite of macros to define and test data quality assertions directly within your dbt project. Integrating these tests into the `dm__npc_counts` pipeline will significantly improve confidence in the data's accuracy and reasonability at each stage.

Tests should be added to the `.yml` schema files corresponding to each model.

### 7.1. General Principles for Applying `dbt-expectations`:

*   **Test at Each Layer:** Apply tests not just to the final `dm__npc_counts` model, but critically to its upstream sources (`stg__cur_cb`), intermediate models (`fct__billing_activity`), and lookups (`lkp__associated_policies`). Catching issues early is more efficient.
*   **Focus on Key Columns:** Prioritize testing columns that are crucial for joins, logic, filtering, and final output.
*   **Combine with Singular Tests:** `dbt-expectations` is excellent for column-level and table-level aggregate assertions. Continue to use dbt's built-in singular tests (or `dbt_utils.test_expression`) for complex business logic validation that spans multiple columns or requires specific scenario setups (as detailed in Section 6.2).
*   **Iterate and Refine:** Start with a core set of expectations and expand as you gain more understanding of the data and potential failure modes. Thresholds for tests like `expect_column_mean_to_be_between` might need adjustment based on observed data.

### 7.2. Recommended `dbt-expectations` Tests for the Pipeline:

Below are examples of how `dbt-expectations` macros can be applied to the models in this pipeline. The exact parameters (e.g., `value_set`, `min_value`, `max_value`, `row_condition`) will need to be determined based on data analysis and business rules.

#### 7.2.1. For `stg__cur_cb` (or equivalent raw billing source):

*   **Non-Nullability of Critical Fields:**
    *   `expect_column_values_to_not_be_null`: For `billing_acct_key`, `billing_activity_date`, `sb_policy_key` (if present here), and the column(s) that will be used to identify NPC events.
*   **Identifier for NPC Events:**
    *   `expect_column_values_to_be_in_set`: If the NPC indicator is a code (e.g., `billing_event_type_code`), ensure it only contains valid codes.
    *   `expect_column_values_to_not_be_null`: For the NPC indicator column, if all records should have this populated.
*   **Date Plausibility:**
    *   `expect_column_values_to_be_between`: For `billing_activity_date`, to catch dates far in the past or future. (e.g., `min_value="2010-01-01"`, `max_value=dbt_date.today()`).
*   **Freshness (if applicable):**
    *   `expect_row_count_to_be_greater_than`: If you expect new billing data daily/hourly.
    *   `expect_column_max_to_be_great_than_or_equal_to`: On `billing_activity_date` or a load timestamp to ensure data is recent.

#### 7.2.2. For `fct__billing_activity`:

*   **Primary Key Integrity:**
    *   `expect_column_values_to_not_be_null`: For `activity_trans_key`.
    *   `expect_column_values_to_be_unique`: For `activity_trans_key`.
*   **Foreign Key Integrity / Referential Integrity:**
    *   `expect_column_values_to_exist_in_other_table`:
        *   `column_name: associated_sb_policy_key`, `other_table: ref('lkp__associated_policies')`, `other_column_name: associated_sb_policy_key`.
*   **Non-Nullability of Key Analytical Columns:**
    *   `expect_column_values_to_not_be_null`: For `associated_policy_key`, `associated_sb_policy_key`, `billing_activity_date`, `billing_activity_amt`.
    *   If an NPC indicator column (e.g., `is_npc_event` or `billing_event_type`) is added/passed through: `expect_column_values_to_not_be_null`.
*   **NPC Indicator Logic:**
    *   `expect_column_values_to_be_in_set`: If `is_npc_event` is boolean/binary (0/1, true/false).
*   **Data Type Consistency (Implicitly handled by dbt, but good for documentation):**
    *   While dbt handles type casting, ensure descriptions reflect expected types.
*   **Plausible Values:**
    *   `expect_column_values_to_be_between`: For `billing_activity_amt` (e.g., not negative if it represents charges, within a reasonable upper bound).
    *   `expect_column_values_to_be_of_type`: Ensure `billing_activity_amt` is numeric.
*   **Date Logic:**
    *   `expect_column_values_to_be_between`: For `billing_activity_date`.

#### 7.2.3. For `lkp__associated_policies`:

*   **Primary Key / Uniqueness:**
    *   `expect_multicolumn_values_to_be_unique`: For `['associated_policy_key', 'associated_sb_policy_key']`.
    *   Consider `expect_multicolumn_values_to_be_unique`: For `['associated_sb_policy_key', 'policy_eff_date']` if this is a business rule relevant to `dm__npc_counts`.
*   **Non-Nullability:**
    *   `expect_column_values_to_not_be_null`: For all key components (`associated_policy_key`, `associated_sb_policy_key`, `policy_chain_id`, `company_numb`, `policy_sym`, `policy_numb`, `policy_module`, `policy_eff_date`).
*   **Referential Integrity:**
    *   `expect_column_values_to_exist_in_other_table`: `policy_chain_id` to `ref('stg__modcom__policy_chain_v3')`.
*   **Date Plausibility:**
    *   `expect_column_values_to_be_between`: For `policy_eff_date`.
*   **Format/Regex (if `policy_key()` output has a known pattern):**
    *   `expect_column_values_to_match_regex`: For `associated_policy_key` if it's a hash or structured string.

#### 7.2.4. For `dm__npc_counts` (Final Model):

*   **Key Integrity:**
    *   `expect_column_values_to_not_be_null`: For `sb_policy_key`, `policy_eff_date`.
    *   `expect_multicolumn_values_to_be_unique`: For `['sb_policy_key', 'policy_eff_date']`.
*   **Count Column Properties:**
    *   For each `prior_yrX_c_activity_count` column:
        *   `expect_column_values_to_not_be_null`.
        *   `expect_column_values_to_be_of_type`: `integer` or `number`.
        *   `expect_column_min_to_be_between`: `min_value=0`, `max_value=0` (i.e., must be >= 0).
        *   `expect_column_mean_to_be_between`: Define a reasonable range for the average count. This helps detect systemic issues or data shifts. E.g., `min_value=0`, `max_value=5` (adjust based on typical NPC frequencies).
        *   `expect_column_max_to_be_between`: Define a reasonable upper limit for NPC counts per policy per year. E.g., `min_value=0`, `max_value=50` (adjust based on business knowledge).
        *   `expect_column_quantile_values_to_be_between`: To check distribution, e.g., p99 should be below a certain threshold.
*   **Amount Sum Column Properties (if retained):**
    *   For each `prior_yrX_c_activity_amount_sum` column:
        *   `expect_column_values_to_not_be_null`.
        *   `expect_column_values_to_be_of_type`: `number`.
        *   `expect_column_mean_to_be_between`: Define a reasonable range.
        *   `expect_column_min_to_be_between`: (e.g. `min_value=0` if amounts are always positive).
*   **Row Count Stability:**
    *   `expect_table_row_count_to_be_between`: Set a range based on the expected number of policies.
    *   `expect_table_row_count_to_equal_other_table_row_count`: Compare row count against `policy_info` CTE (might require materializing `policy_info` or using a custom test if `policy_info` is complex). A simpler check is `expect_row_count_to_match_expression(expression="select count(distinct sb_policy_key, policy_eff_date) from {{ ref('lkp__associated_policies') }}")` if that grain is stable.
*   **Relationship Between Columns (More Advanced):**
    *   `expect_column_pair_values_A_to_be_greater_than_B`: Not directly applicable here but illustrates the type of cross-column checks available.

### 7.3. Implementation Steps:

1.  **Review `dbt-expectations` Documentation:** Familiarize the team with the full range of available macros and their parameters from the official package documentation (especially for v0.10.4).
2.  **Create/Update Schema Files:** For each model (`.sql` file), ensure a corresponding `.yml` file exists in the same directory (or a subdirectory like `models/05_mrt/_mrt_schema.yml`).
3.  **Add Tests:** Within the `.yml` files, under the `columns` list for each model, add `tests:` entries using the `dbt-expectations` macros.
    ```yaml
    # Example for models/05_mrt/dm__npc_counts.yml (or equivalent)
    version: 2

    models:
      - name: dm__npc_counts
        columns:
          - name: sb_policy_key
            tests:
              - not_null
              - dbt_expectations.expect_column_values_to_not_be_null
          - name: policy_eff_date
            tests:
              - not_null
          - name: prior_yr1_c_activity_count
            tests:
              - dbt_expectations.expect_column_values_to_not_be_null
              - dbt_expectations.expect_column_min_to_be_between:
                  min_value: 0
                  max_value: 0 # Ensures >= 0
              - dbt_expectations.expect_column_mean_to_be_between:
                  min_value: 0.0
                  max_value: 2.0 # Example: adjust based on data
                  strictly: false
    ```
4.  **Run `dbt test`:** Execute `dbt test` to validate the expectations.
5.  **Refine and Monitor:** Adjust test parameters as needed based on failures and a better understanding of the data. Regularly run tests as part of your dbt workflow and CI/CD pipeline.

By systematically applying these tests, you will build a strong set of guardrails around your data pipeline, leading to a much more believable and trustworthy `dm__npc_counts` model.
