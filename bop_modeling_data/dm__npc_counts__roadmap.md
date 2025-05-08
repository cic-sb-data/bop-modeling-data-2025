# Roadmap for Implementing dm__npc_counts (Aligned with current_npc_logic.sas)

## 1. Introduction and Objective

This document outlines the step-by-step procedure for developing the `dm__npc_counts` dbt model. The primary objective is to calculate Non-Payment Cancellation (NPC) counts for insurance policies, strictly adhering to the business logic defined in the `current_npc_logic.sas` file.

**Key Guiding Document:** The detailed data lineage, specific logic, and step-by-step CTE approach for this model are documented in `npc-counts.md`. This roadmap serves as a high-level plan for executing the implementation described therein.

**Crucial Distinction:** The logic implemented (particularly prior year window definitions and the 4-month lag for the first prior year) is based *exclusively* on `current_npc_logic.sas`. This differs from other generalized SAS macros (e.g., `%make_prior_year_cols`) discussed previously. This roadmap and the resulting model will align with `npc-counts.md`.

## 2. Prerequisite Data and Upstream Models

Before building `dm__npc_counts`, ensure the following upstream dbt models are available, tested, and provide the necessary fields as detailed in `npc-counts.md`:

*   **`lkp__associated_policies` (or `lkp__sb_policy_key`)**:
    *   **Role**: Provides the universe of target policies (`sb_policy_key`), their effective dates (`policyeffectivedate`), and `policy_chain_id`.
    *   **Key Fields**: `associated_sb_policy_key` (as `sb_policy_key`), `policy_eff_date` (as `policyeffectivedate`), `policy_chain_id`, and other policy-identifying attributes.
*   **`stg__modcom__policy_chain_v3`**:
    *   **Role**: Links billing records (via their full policy keys) to `policy_chain_id`.
    *   **Key Fields**: `policy_chain_id`, `COMPANY_NUMB`, `POLICY_SYM`, `POLICY_NUMB`, `POLICY_MODULE`, `POLICY_EFF_DATE`.
*   **`stg__screngn__xcd_bil_policy`**:
    *   **Role**: Provides `bil_account_id` associated with policy terms.
    *   **Key Fields**: `bil_account_id`, and policy component fields for joining to `stg__modcom__policy_chain_v3`.
*   **`stg__screngn__xcd_bil_act_summary`**:
    *   **Role**: Source of NPC events and their activity dates.
    *   **Key Fields**: `bil_account_id`, `bil_acy_dt`, `bil_acy_des_cd`, `bil_des_rea_typ`.

## 3. dbt Model Implementation Steps (`dm__npc_counts.sql`)

The `dm__npc_counts` model will be constructed using a series of Common Table Expressions (CTEs), following the detailed plan in `npc-counts.md`:

1.  **CTE: `target_policies_with_cutoffs`**
    *   **Purpose**: Select target policies and calculate all necessary date cutoffs (`bil_eval_date`, `bil_prev_1yr_start/end`, etc.) based on `policyeffectivedate`, strictly following `current_npc_logic.sas` (e.g., 4-month lag for 1st prior year window, 12-month windows for subsequent prior years).
    *   **Source**: `lkp__associated_policies`.

2.  **CTE: `billing_accounts_to_chains`**
    *   **Purpose**: Link `bil_account_id` from billing data to `policy_chain_id` by joining billing policy terms with the policy chain information.
    *   **Sources**: `stg__screngn__xcd_bil_policy`, `stg__modcom__policy_chain_v3`.

3.  **CTE: `policies_linked_to_billing_accounts`**
    *   **Purpose**: Join target policies with their associated `bil_account_id`(s) via `policy_chain_id`. Create an indicator (`cinbill_acct_by_chain_exists_ind`) to flag policies that successfully link to a billing account.
    *   **Sources**: `target_policies_with_cutoffs`, `billing_accounts_to_chains`.

4.  **CTE: `npc_events_raw`**
    *   **Purpose**: Filter billing activities to identify raw NPC events based on `bil_acy_des_cd = 'C'` AND `bil_des_rea_typ = ''`.
    *   **Source**: `stg__screngn__xcd_bil_act_summary`.

5.  **CTE: `policy_npc_event_counts`**
    *   **Purpose**: Join policies (with their billing accounts) to NPC events. Filter events to those occurring *before* the `policyeffectivedate`. Group by policy and its attributes, and sum NPC events falling into each of the five defined prior year windows.
    *   **Sources**: `policies_linked_to_billing_accounts`, `npc_events_raw`.

6.  **CTE: `final_npc_counts`**
    *   **Purpose**: Aggregate counts per `sb_policy_key` (if fanned out by multiple billing accounts per chain). Apply `NULL` logic for NPC counts if `cinbill_acct_by_chain_exists_ind = 0`. Calculate cumulative NPC counts (`NPC_cprev2` through `NPC_cprev5`).
    *   **Source**: `policy_npc_event_counts`.

7.  **Final `SELECT` Statement**:
    *   Select all required columns as specified in `npc-counts.md` (e.g., `sb_policy_key`, `policyeffectivedate`, `bil_eval_date`, individual and cumulative NPC counts) from `final_npc_counts`.
    *   Ensure column names and output structure align with the target (derived from SAS `BOP_cincibill`).

## 4. Testing Strategy

A comprehensive testing strategy is crucial. Refer to the project's `data-testing-plan.md` for general principles. For `dm__npc_counts` specifically:

*   **Upstream Data Validation**: Ensure all source models listed in Section 2 are thoroughly tested for accuracy and completeness.
*   **Logic Validation (Unit Tests for CTEs where feasible or for the final model):**
    *   **Date Cutoffs**: Verify `bil_eval_date` and prior year window start/end dates are calculated correctly according to `current_npc_logic.sas`.
    *   **NPC Event Identification**: Confirm that only records with `bil_acy_des_cd = 'C'` and `bil_des_rea_typ = ''` are counted.
    *   **Prior Year Assignment**: Test that NPC events are correctly assigned to the defined prior year windows (prev_1 through prev_5).
    *   **Aggregation**: Ensure counts are summed correctly per policy.
    *   **NULL Handling**: Verify policies with no linked `bil_account_id` (via `policy_chain_id`) have `NULL` for all NPC count fields.
    *   **Exclusion of Future Events**: Confirm events on or after `policyeffectivedate` are not counted.
*   **Referential Integrity**:
    *   Test that every `sb_policy_key` and `policyeffectivedate` combination in `dm__npc_counts` exists in `lkp__associated_policies`.
*   **Output Validation**:
    *   Compare output against manually calculated scenarios for a diverse set of sample policies (e.g., no NPCs, NPCs in one year, NPCs in multiple years, NPCs just before/after window boundaries).
    *   If feasible, compare against output from `current_npc_logic.sas` for a small, controlled dataset.
    *   All count columns must be non-negative or NULL.
*   **dbt Tests**: Implement schema tests (e.g., `not_null`, `unique` on primary key `sb_policy_key, policyeffectivedate`) and singular/generic tests for the specific logic points above.

## 5. Documentation

*   **Model and Column Descriptions**: Create/update dbt documentation for `dm__npc_counts` and all its columns. Clearly describe the source of logic (i.e., `current_npc_logic.sas` via `npc-counts.md`).
*   **`npc-counts.md`**: This file will remain the primary, detailed technical specification for the model's logic, data lineage, and CTE breakdown.
*   **This Roadmap (`dm__npc_counts__roadmap.md`)**: Serves as the high-level plan and checklist for implementation.

## 6. Review and Deployment

*   **Code Review**: Conduct a thorough peer review of the `dm__npc_counts.sql` model code and associated tests.
*   **Test Execution**: Ensure all dbt tests pass.
*   **Performance Review**: Assess query performance and optimize if necessary.
*   **Stakeholder Sign-off (if applicable)**: Review outputs and logic with business stakeholders to confirm alignment with requirements.
*   **Deployment**: Deploy the model to the production environment.

By following these steps, we will produce a well-understood, accurate, and robust `dm__npc_counts` model that faithfully implements the specified SAS logic.
