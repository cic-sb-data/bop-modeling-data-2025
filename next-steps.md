# Next Steps for BOP Modeling Data Project

This document outlines the detailed step-by-step checklist for the `bop_modeling_data` dbt project, focusing on delivering a production-grade `dm__npc_counts` model. It references the `current-state.md` for project status and `dm__npc_counts__roadmap.md` for the strategic plan.

## I. Foundational Setup & Documentation (Referencing `current-state.md`)

*   [ ] **Populate `sources.yml`**:
    *   **Action**: Formally define all data sources (`screngn`, `decfile`, `modcom`) in `bop_modeling_data/models/sources.yml`.
    *   **Reference**: `current-state.md` (Section 2: Data Sources) notes this as a critical need.
*   [ ] **Clarify and Populate `variables.md`**:
    *   **Action**: Define all dbt variables used in the project or confirm if it's not used and document this.
    *   **Reference**: `current-state.md` (Section 5: Documentation) notes its minimal current state.
*   [ ] **Enhance Project READMEs**:
    *   **Action**: Expand `bop_modeling_data/README.md` with a specific overview of this dbt project.
    *   **Reference**: `current-state.md` (Section 5: Documentation).
*   [ ] **Review and Integrate Supporting Markdown**:
    *   **Action**: Review `lkp__associated_policies.md` and `npc-counts.md`. Update, integrate into dbt docs, or archive if redundant.
    *   **Reference**: `current-state.md` (Section 5: Documentation).

## II. Implement Core SAS-Defined Requirements for NPC Logic (Referencing `dm__npc_counts__roadmap.md`)

*   [ ] **Correct or Replace `make_n_prior_year_cols.sql` Macro**:
    *   **Action**: Modify the existing dbt macro `bop_modeling_data/macros/make_n_prior_year_cols.sql` to accurately replicate the SAS `%make_prior_year_cols` logic. This includes:
        *   [ ] Correct `eval_date` calculation considering `n_month_lag`.
        *   [ ] Implement SAS-aligned prior year window definitions (`yrX_prior_date`).
        *   [ ] Ensure correct slotting of transactions, including `nth_prior_year = 0` for recent activities within the lag period.
    *   **Reference**: `dm__npc_counts__roadmap.md` (Sections 1.1, 1.2, 1.3).
    *   **Alternative**: If modifying the macro is too complex, develop the SAS-compliant logic directly within the `dm__npc_counts` model.
*   [ ] **Verify NPC Event Definition in Billing Data**:
    *   **Action**: Investigate `stg__cur_cb` (sourced from `screngn`) to confirm how Non-Payment Cancellation (NPC) events are identified (e.g., specific codes like `bil_acy_des_cd = 'C'` and `bil_des_rea_typ = ''`).
    *   **Reference**: `dm__npc_counts__roadmap.md` (Sections 4.2.1, 5.1). `current-state.md` (Section 2: Data Sources - `screngn`, `current_cincibill`).
    *   **Contingency**: If NPC indicators are not clearly available, this becomes a critical data gap requiring a separate plan to source or derive this information.

## III. Refine Upstream Models (Referencing `dm__npc_counts__roadmap.md` & `current-state.md`)

*   [ ] **`fct__billing_activity` Refinement**:
    *   **Action**: Ensure `fct__billing_activity` correctly sources and transforms data from `stg__cur_cb`.
        *   [ ] Confirm it includes necessary fields for NPC identification (e.g., `bil_acy_des_cd`, `bil_des_rea_typ`) and `billing_activity_date`, `sb_policy_key`.
        *   [ ] Verify the grain and uniqueness of `activity_trans_key`.
    *   **Reference**: `dm__npc_counts__roadmap.md` (Section 2.2). `current-state.md` (Section 3: Models - Fact Layer).
*   [ ] **`lkp__associated_policies` Review**:
    *   **Action**: Confirm `lkp__associated_policies` accurately links `sb_policy_key` to policy chain information and provides correct `policy_eff_date` for each associated policy.
        *   [ ] Verify sources: `stg__decfile__sb_policy_lookup` and `stg__modcom__policy_chain_v3`.
        *   [ ] Ensure `policy_key()` macro usage is correct and types are consistent.
    *   **Reference**: `dm__npc_counts__roadmap.md` (Section 2.1). `current-state.md` (Section 3: Models - Lookup Layer).
*   [ ] **Complete Schema Documentation for Upstream Models**:
    *   **Action**: Review and complete model and column descriptions in `_schema.yml` files for all models in the `00_raw`, `01_stg`, `02_lkp`, and `03_fct` layers that feed into `dm__npc_counts`.
    *   **Reference**: `current-state.md` (Section 5: Documentation - Areas for Improvement).

## IV. Modify `dm__npc_counts` Model Logic to Align with SAS (Referencing `dm__npc_counts__roadmap.md`)

*   [ ] **Update `dm__npc_counts.sql` CTEs**:
    *   **Action**: Rewrite the CTEs in `bop_modeling_data/models/05_mrt/dm__npc_counts.sql`.
        *   [ ] **`pc_billing_activity` (formerly `billing_activity`)**: Filter for actual NPC events based on confirmed codes (Step II).
        *   [ ] **`policy_info`**: Ensure this correctly sources `sb_policy_key` and the definitive `policy_eff_date` from `lkp__associated_policies` to be used as the reference date for prior year calculations.
        *   [ ] **`policy_and_npc_activity` (or similar join CTE)**: Efficiently join filtered NPC events with policy information. Pre-filter events to only those occurring *before* the `policy_eff_date`.
        *   [ ] **`activity_with_sas_prior_year`**: Apply the corrected `make_n_prior_year_cols` macro (or equivalent custom logic) to this joined data.
        *   [ ] **`aggregated_npc_counts_by_sas_year`**: Aggregate NPC counts per policy per SAS-defined prior year, ensuring `nth_prior_year` from 0 to 5 are handled.
        *   [ ] **`final_pivoted_counts`**: Pivot these counts into `prior_yrX_c_activity_count` columns. Ensure all policies from `policy_info` are present, coalescing null counts to 0.
    *   **Reference**: `dm__npc_counts__roadmap.md` (Sections 1.3, 3, 5.2).
*   [ ] **Clarify/Remove `_amount_sum` Columns**:
    *   **Action**: Confirm with stakeholders if summed amounts for NPC events are required. If not, remove these calculations to simplify the model.
    *   **Reference**: `dm__npc_counts__roadmap.md` (Section 4.2.2, 5.1).

## V. Implement Comprehensive Data Testing (Referencing `dm__npc_counts__roadmap.md` & `data-testing-plan.md`)

*   [ ] **Upstream Model Testing (Leverage `dbt-expectations` and schema tests)**:
    *   **Action**: Implement tests for `stg__cur_cb`, `fct__billing_activity`, `lkp__associated_policies` as outlined in `dm__npc_counts__roadmap.md` (Section 7.2) and `data-testing-plan.md`.
        *   [ ] `stg__cur_cb`: Non-nulls, NPC identifiers, date plausibility.
        *   [ ] `fct__billing_activity`: Primary key, foreign keys, non-nulls for analytical columns, NPC indicator logic.
        *   [ ] `lkp__associated_policies`: Uniqueness, non-nulls, referential integrity, date plausibility.
*   [ ] **`dm__npc_counts` Specific Logic Tests (Singular Tests)**:
    *   **Action**: Implement singular tests for scenarios detailed in `dm__npc_counts__roadmap.md` (Section 6.2).
        *   [ ] No prior NPC activity.
        *   [ ] NPC activity in specific prior year.
        *   [ ] NPC activity spanning multiple prior years.
        *   [ ] NPC activity outside 5-year lookback.
        *   [ ] NPC activity on or after policy effective date.
        *   [ ] Boundary condition tests for year calculation.
        *   [ ] Key integrity (all `sb_policy_key` from `policy_info` in output).
        *   [ ] Non-negative counts.
*   [ ] **`dm__npc_counts` Aggregate Reasonableness (using `dbt-expectations`)**:
    *   **Action**: Implement tests as per `dm__npc_counts__roadmap.md` (Section 7.2.4).
        *   [ ] Key integrity (`sb_policy_key`, `policy_eff_date` uniqueness).
        *   [ ] Count column properties (e.g., `expect_column_values_to_be_between min_value=0`).
        *   [ ] Row count stability/matching.
*   [ ] **Review and Expand Existing Generic and Singular Tests**:
    *   **Action**: Review tests in `bop_modeling_data/tests/generic/` and `bop_modeling_data/tests/singular/`.
    *   **Reference**: `current-state.md` (Section 4: Tests).

## VI. Optimize Performance (Referencing `dm__npc_counts__roadmap.md`)

*   [ ] **Filter Early**:
    *   **Action**: Ensure NPC event filtering is applied as early as possible, ideally in the first CTE handling billing data within `dm__npc_counts` or even upstream in `fct__billing_activity` if appropriate.
    *   **Reference**: `dm__npc_counts__roadmap.md` (Section 5.2.1).
*   [ ] **Optimize Joins**:
    *   **Action**: Ensure joins between policy information and NPC events are on indexed/well-distributed keys and that pre-filtering is effective.
    *   **Reference**: `dm__npc_counts__roadmap.md` (Section 5.2.2).
*   [ ] **Evaluate Materialization Strategy**:
    *   **Action**: Confirm `table` materialization for `dm__npc_counts` is appropriate. Consider incremental strategies if full refreshes are too slow and data allows.
    *   **Reference**: `dm__npc_counts__roadmap.md` (Section 5.2.4).

## VII. Enhance Documentation and Review Processes (Referencing `dm__npc_counts__roadmap.md` & `current-state.md`)

*   [ ] **Inline Model Comments**:
    *   **Action**: Add detailed comments within the SQL code for `dm__npc_counts` and its complex upstream models, explaining each CTE's purpose and logic.
    *   **Reference**: `current-state.md` (Section 5: Documentation - Areas for Improvement).
*   [ ] **dbt Docs Generation**:
    *   **Action**: Regularly run `dbt docs generate` and `dbt docs serve`. Ensure all models and columns in the `dm__npc_counts` lineage have complete and accurate descriptions.
    *   **Reference**: `dm__npc_counts__roadmap.md` (Section 6.4).
*   [ ] **Code Reviews**:
    *   **Action**: Institute mandatory peer reviews for all changes to `dm__npc_counts` and its critical upstream dependencies.
    *   **Reference**: `dm__npc_counts__roadmap.md` (Section 6.4).
*   [ ] **Stakeholder Validation**:
    *   **Action**: Schedule sessions to review the logic and outputs of `dm__npc_counts` with business stakeholders to ensure continued alignment.
    *   **Reference**: `dm__npc_counts__roadmap.md` (Section 6.4).

## VIII. Monitoring and Maintenance (Referencing `dm__npc_counts__roadmap.md`)

*   [ ] **Regular dbt Runs and Tests**:
    *   **Action**: Integrate `dbt run` and `dbt test` into a regular workflow (e.g., CI/CD pipeline).
*   [ ] **Monitor Test Results and Runtimes**:
    *   **Action**: Actively monitor test outcomes and model runtimes. Investigate failures or significant performance degradations.
*   [ ] **Trend Analysis and Data Profiling**:
    *   **Action**: Periodically profile `dm__npc_counts` and key upstream models using `dbt-profiler` or `dbt-eda-tools` to monitor distributions and detect anomalies.
    *   **Reference**: `dm__npc_counts__roadmap.md` (Section 6.3).

This checklist provides a structured approach to achieving a production-ready `dm__npc_counts` model. It should be treated as a living document and updated as the project progresses.
