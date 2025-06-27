# Billing Variables SAS-to-dbt Conversion Outline

## 1. Inputs

### a. Policy Lookup Table
- **Model:** `stg__decfile__sb_policy_lookup`
- **Grain:** One row per policy-lob (`sb_policy_key`)
- **Purpose:** Provides the set of policies to process, with chain IDs and policy keys.

### b. Policy Image Table
- **Model:** `stg__decfile__sb_aiv_lookup`
- **Grain:** One row per policy image (`sb_aiv_key`)
- **Purpose:** Provides detailed policy image/location information for each policy.

### c. Policy Chain Table
- **Model:** `stg__modcom__policy_chain_v3`
- **Grain:** One row per policy chain/policy combination
- **Purpose:** Maps policies to their chain IDs for grouping related policies.

### d. Billing Policy Table
- **Model:** `stg__screngn__xcd_bil_policy`
- **Grain:** One row per billing account and policy
- **Purpose:** Maps policies to billing accounts.

### e. Billing Activity Summary Table
- **Model:** `stg__screngn__xcd_bil_act_summary`
- **Grain:** One row per billing account transaction
- **Purpose:** Contains billing activity, including non-pay cancellations.

## 2. Outputs

### a. Policy-Chain-Date Cutoffs Table
- **Model:** (intermediate, e.g. `cfxml_pols_chains_cutoffs`)
- **Grain:** One row per policy image
- **Contents:** Policy identifiers, chain ID, calculated claim and billing evaluation dates and cutoffs.

### b. Policy to Billing Account Mapping Table
- **Model:** (intermediate, e.g. `init_inforce_to_cinbil_acct`)
- **Grain:** One row per policy image
- **Contents:** Policy identifiers, chain ID, billing account IDs, evaluation/cutoff dates, indicator for billing account existence.

### c. Non-Pay Cancel Counts Table
- **Model:** (intermediate, e.g. `rnpc_count_prev_2`)
- **Grain:** One row per policy image
- **Contents:** Non-pay cancel counts for previous 1-5 years and cumulative counts.

### d. Final Billing Variables Table
- **Model:** `BOP_cincibill` (or `fct__billing_variables`)
- **Grain:** One row per policy image
- **Contents:** Policy identifiers, chain ID, evaluation dates, non-pay cancel counts.

## 3. Step-by-Step Process

1. **Extract Distinct Policy IDs**
   - **Input:** `stg__decfile__sb_policy_lookup`
   - **Output:** Unique policy IDs for each LOB.
   - **Purpose:** Identify all unique policies for each LOB.

2. **Build Policy Image Keys**
   - **Input:** Policy IDs, `stg__decfile__sb_aiv_lookup`
   - **Output:** Policy image details for each policy.
   - **Purpose:** Map each policy to its image details.

3. **Deduplicate Policy Keys**
   - **Input:** Combined policy keys
   - **Output:** Deduplicated set.
   - **Purpose:** Ensure one row per policy image.

4. **Join to Policy Chain Table and Calculate Date Cutoffs**
   - **Input:** Deduplicated policy keys, `stg__modcom__policy_chain_v3`
   - **Output:** Policy-chain-date cutoffs.
   - **Purpose:** Attach chain IDs and calculate claim/billing evaluation and cutoff dates.

5. **Map Policies to Billing Accounts**
   - **Input:** `stg__screngn__xcd_bil_policy`
   - **Output:** Policy to billing account mapping.
   - **Purpose:** Map policy symbol/number to billing accounts and chain IDs.

6. **Join Policy Chains to Billing Accounts**
   - **Input:** Policy-chain-date cutoffs, billing account mapping
   - **Output:** Policy image with billing account info and existence indicator.

7. **Extract Non-Pay Cancel Transactions**
   - **Input:** `stg__screngn__xcd_bil_act_summary`
   - **Output:** Filtered non-pay cancel transactions.

8. **Calculate Non-Pay Cancel Counts by Year**
   - **Input:** Policy to billing account mapping, non-pay cancel transactions
   - **Output:** Non-pay cancel counts for each policy and period.

9. **Assemble Final Billing Variables Table**
    - **Input:** Policy-chain-date cutoffs, non-pay cancel counts
    - **Output:** Final table with all policy, chain, evaluation, and non-pay cancel count variables.

10. **Cleanup Temporary Tables**
    - **Input:** All intermediate tables
    - **Purpose:** Remove temp tables to keep workspace clean.

## 4. Coding Strategy and Architecture

- **Atomic, Testable Models:**  
  Each transformation step should be a separate dbt model, with clear inputs and outputs, and dbt tests (uniqueness, not null, value ranges) at each stage.

- **Use of Staging Models:**  
  All raw data should be referenced via staging models (as already implemented in your dbt project).

- **Consistent Keys:**  
  Use stable, unique keys (e.g., `sb_policy_key`, `sb_aiv_key`) for joins and deduplication.

- **Window and Date Logic:**  
  Implement date cutoffs and rolling window logic using dbt SQL, matching the SAS `intnx` logic for evaluation/cutoff periods.

- **Cumulative and Windowed Counts:**  
  Calculate non-pay cancel counts for each window and cumulative period using SQL aggregation.

- **Final Fact Table:**  
  The final model should present one row per policy image, with all derived variables and counts, suitable for downstream analytics.

- **Testing:**  
  Add dbt tests for uniqueness, not null, and value ranges at each step. Use custom tests for business logic where needed.

- **Documentation:**  
  Document each model with descriptions of inputs, outputs, and logic for maintainability.

---

## Roadmap

A step-by-step checklist to reach a Minimum Viable Product (MVP):

1. **Validate Staging Models**
   - [x] Confirm all required staging models exist and are populated:  
     - `stg__decfile__sb_policy_lookup`
     - `stg__decfile__sb_aiv_lookup`
     - `stg__modcom__policy_chain_v3`
     - `stg__screngn__xcd_bil_policy`
     - `stg__screngn__xcd_bil_act_summary`
   - [x] Add basic dbt tests (not_null, unique) to key columns in staging models.

   **Developer Notes:**  
   - All required staging models are present in the codebase and materialize as expected.
   - Each staging model has a corresponding schema YAML file with at least `not_null` and `unique` tests on primary key columns (e.g., `sb_policy_key`, `sb_aiv_key`, `policy_chain_id`, etc.).
   - Data in each staging model has been visually inspected for row counts and key integrity.
   - If you add new columns or change key logic, update the schema YAMLs and add/adjust tests accordingly.
   - Proceed to implement the core transformation models, referencing these staging models as sources.

2. **Implement Core Transformation Models**
   - [x] 01__extract_distinct_policy_ids: Extract unique policy IDs.
   - [x] 02__build_policy_image_keys: Join policy IDs to policy images.
   - [x] 03__deduplicated_policy_keys: Deduplicate to one row per policy image.
   - [x] 04__join_policy_keys_to_policy_chains_and_calculate_date_cutoffs: Attach chain IDs and calculate date cutoffs.
   - [x] 05__map_policies_to_billing_accounts: Map policies to billing accounts.
   - [x] 06__join_policy_chains_to_billing_accounts: Join chains to billing accounts, add existence indicator.
   - [x] 07__extract_non_pay_cancellation_transactions: Filter for non-pay cancel transactions.
   - [x] 08__calculate_non_pay_cancel_counts_by_year: Calculate non-pay cancel counts for each window.
   - [x] 09__assemble_final_billing_variables_table: Assemble the final output.

3. **Testing and Validation**
   - [x] Add dbt tests for uniqueness, not_null, and value ranges at each step.
   - [x] Add custom tests for business logic (e.g., correct windowing, counts).
   - [x] Validate row counts and key integrity between steps.

4. **Documentation**
   - [x] Add descriptions to all models and columns.
   - [x] Document business logic and any assumptions.

   **Developer Notes:**  
   - All dbt models and columns are now documented with descriptions in their respective `.yml` files.
   - The business logic for each step is described in this file and in the model-level docs.
   - For reference, here are code snippets from both dbt and SAS for the final output step:

   **dbt Final Output Model:**
   ````jinja-sql
   // filepath: /home/aweaver/work/bop-modeling-data-2025/bop_modeling_data/models/03_fct/billing/09__assemble_final_billing_variables_table.sql
   with
   cutoffs as (
       select *
       from {{ ref('04__join_policy_keys_to_policy_chains_and_calculate_date_cutoffs') }}
   ),
   npc_counts as (
       select *
       from {{ ref('08__calculate_non_pay_cancel_counts_by_year') }}
   )
   select
       c.sb_aiv_key as policy_image_key,
       c.image_eff_date,
       c.image_exp_date,
       c.policy_chain_id,
       c.company_numb,
       c.policy_sym,
       c.policy_numb,
       c.policy_module,
       c.policy_eff_date,
       c.bil_eval_date,
       n.NonPayCancel_Count_prev_1 as npc_prev1,
       n.NonPayCancel_Count_prev_2 as npc_prev2,
       n.NonPayCancel_Count_prev_3 as npc_prev3,
       n.NonPayCancel_Count_prev_4 as npc_prev4,
       n.NonPayCancel_Count_prev_5 as npc_prev5,
       n.NonPayCancel_Count_cprev_2 as npc_cprev2,
       n.NonPayCancel_Count_cprev_3 as npc_cprev3,
       n.NonPayCancel_Count_cprev_4 as npc_cprev4,
       n.NonPayCancel_Count_cprev_5 as npc_cprev5
   from cutoffs c
   left join npc_counts n
       on c.sb_aiv_key = n.sb_aiv_key
   order by c.sb_aiv_key
   ````

   **SAS Final Output Step:**
   ````sas
   proc sql;
   create table BOP_cincibill as select 
       t1.cfxmlid
       ,t1.imageeffectivedate
       ,t1.imageexpirationdate
       ,t1.policy_chain_id
       ,t1.companycode
       ,t1.policysymbol
       ,t1.policynumber
       ,t1.statisticalpolicymodulenumber
       ,t1.policyeffectivedate
       ,t1.bil_eval_date
       ,t2.NonPayCancel_Count_prev_1 as NPC_prev1
       ,t2.NonPayCancel_Count_prev_2 as NPC_prev2
       ,t2.NonPayCancel_Count_prev_3 as NPC_prev3
       ,t2.NonPayCancel_Count_prev_4 as NPC_prev4
       ,t2.NonPayCancel_Count_prev_5 as NPC_prev5
       ,t2.NonPayCancel_Count_cprev_2 as NPC_cprev2
       ,t2.NonPayCancel_Count_cprev_3 as NPC_cprev3
       ,t2.NonPayCancel_Count_cprev_4 as NPC_cprev4
       ,t2.NonPayCancel_Count_cprev_5 as NPC_cprev5
   from cfxml_pols_chains_cutoffs as t1
   left join rnpc_count_prev_2 as t2
        on t1.cfxmlid = t2.cfxmlid
   Order by t1.cfxmlid
   ; quit;
   ````

   - All business logic and output columns are aligned with the SAS program.
   - If you add new columns or change logic, update both the SQL and documentation accordingly.

5. **MVP Output**
   - [x] Ensure the final model (`fct__billing_variables` or equivalent) matches the expected grain and columns.
   - [x] Validate against legacy SAS output for a sample period.

6. **Cleanup and Review**
   - [ ] Remove or archive any obsolete intermediate tables/models.
   - [ ] Peer review and QA.

---

This roadmap provides a clear, actionable path to deliver a working MVP for billing variables in dbt, with documentation and code blocks for reference.