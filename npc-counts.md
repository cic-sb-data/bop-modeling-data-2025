# Checklist: Create dm__npc_counts Datamart Model

This checklist outlines the steps to create a dbt model (`dm__npc_counts`) that aggregates prior billing activities (specifically those with description code 'C') based on the `sb_policy_key` and its associated policy chain history.

This model will be used as a feature in an underwriting model on renewal policies to identify the number of non-payment cancellation (NPC) activities in prior years 1-5. So we need to look at the policies that are associated with the current sb_policy_key and the billing activities that occurred prior to the policy effective date.

## Steps to Create `dm__npc_counts` Model

1.  **Identify Source Tables:**
    *   `fct__billing_activity`: Contains billing activity details including `associated_policy_key`, `billing_activity_date`, `billing_activity_amount`, and `billing_activity_description_code`.
    *   `lkp__associated_policies`: Links `associated_policy_key` to `sb_policy_key` and `policy_chain_id`.
    *   `lkp__sb_policy_key`: Provides the primary `policy_eff_date` for each `sb_policy_key`.

2.  **CTE 1: `base_c_activities`**
    *   Select `associated_policy_key`, `billing_activity_date`, `billing_activity_amount`.
    *   From `{{ ref('fct__billing_activity') }}`.
    *   Filter `where billing_activity_description_code = 'C'`.

3.  **CTE 2: `policy_keys`**
    *   Select `associated_policy_key`, `sb_policy_key`, `policy_chain_id`.
    *   From `{{ ref('lkp__associated_policies') }}`.

4.  **CTE 3: `sb_policy_dates`**
    *   Select distinct `sb_policy_key`, `policy_eff_date`.
    *   From `{{ ref('lkp__sb_policy_key') }}`.

5.  **CTE 4: `joined_activities_keys_dates`**
    *   Join `base_c_activities` with `policy_keys` on `associated_policy_key`.
    *   Join the result with `sb_policy_dates` on `sb_policy_key`.
    *   Select `sb_policy_key`, `policy_chain_id`, `policy_eff_date` (from `sb_policy_dates`), `billing_activity_date`, `billing_activity_amount`.

6.  **CTE 5: `prior_year_activities`**
    *   Apply the `{{ make_n_prior_year_cols('joined_activities_keys_dates', relative_date='policy_eff_date', compare_date='billing_activity_date', n_prior_years=5) }}` macro. This should add a column like `nth_prior_year`.
    *   Filter the results from the macro: `where billing_activity_date < policy_eff_date` and `nth_prior_year <= 5`.

7.  **CTE 6: `aggregated_prior_c_by_year`**
    *   Select `sb_policy_key`, `nth_prior_year`.
    *   Calculate `count(*) as c_activity_count`.
    *   Calculate `sum(billing_activity_amount) as c_activity_amount_sum`.
    *   From `prior_year_activities`.
    *   Group by `sb_policy_key`, `nth_prior_year`.

8.  **Final Select:**
    *   Start with a distinct set of `sb_policy_key`, `policy_chain_id`, `policy_eff_date` from `joined_activities_keys_dates` (or join `sb_policy_dates` back to `policy_keys`). Let's call this `base_policies`.
    *   Left join `aggregated_prior_c_by_year` to `base_policies` on `sb_policy_key`.
    *   Pivot the results using conditional aggregation (e.g., `SUM(CASE WHEN nth_prior_year = 1 THEN c_activity_count ELSE 0 END)`) grouped by `sb_policy_key`, `policy_chain_id`, `policy_eff_date`.
    *   Create columns:
        *   `prior_yr1_c_activity_count`, `prior_yr1_c_activity_amount_sum`
        *   `prior_yr2_c_activity_count`, `prior_yr2_c_activity_amount_sum`
        *   `prior_yr3_c_activity_count`, `prior_yr3_c_activity_amount_sum`
        *   `prior_yr4_c_activity_count`, `prior_yr4_c_activity_amount_sum`
        *   `prior_yr5_c_activity_count`, `prior_yr5_c_activity_amount_sum`
    *   Use `coalesce` on the final pivoted columns to ensure they default to 0.

9.  **Documentation & Tests (`_schema.yml`):**
    *   Update the model description to mention per-year aggregation.
    *   Define columns: `sb_policy_key`, `policy_chain_id`, `policy_eff_date`, and the 10 pivoted columns (e.g., `prior_yr1_c_activity_count`, `prior_yr1_c_activity_amount_sum`, ... `prior_yr5_c_activity_amount_sum`).
    *   Add `unique` and `not_null` tests to `sb_policy_key`.
    *   Add range tests (`>= 0`) to all count columns.

10. **Build and Test:**
    *   Run `dbt build --select dm__npc_counts` (or `dbt run` and `dbt test`).
    *   Verify results and test outcomes.