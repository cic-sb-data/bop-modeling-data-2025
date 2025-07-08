# Billing Variables SAS-to-dbt Conversion Outline

## 1. Inputs

All inputs should be referenced via dbt staging models, not raw tables. The key staging models are:

- **stg__screngn__bil_policy**  
  Maps policies to billing accounts.

- **stg__screngn__bil_act_summary**  
  Contains billing activity, including non-pay cancellations.

- **stg__decfile__sb_policy_lookup**  
  Provides policy keys, chain IDs, and policy-lob mapping.

- **stg__decfile__sb_aiv_lookup**  
  Provides detailed policy image information for each policy and location.

- **stg__modcom__policy_chain_v3**  
  Maps policies to their chain IDs for grouping related policies.

## 2. Outputs

### a. Policy-Chain-Date Cutoffs Table
- **Table:** `cfxml_pols_chains_cutoffs`
- **Grain:** One row per policy image (`cfxmlid`)
- **Contents:** Policy identifiers, chain ID, calculated claim and billing evaluation dates and cutoffs.

### b. Policy to Billing Account Mapping Table
- **Table:** `init_inforce_to_cinbil_acct`
- **Grain:** One row per policy image (`cfxmlid`)
- **Contents:** Policy identifiers, chain ID, billing account IDs, evaluation/cutoff dates, indicator for billing account existence.

### c. Non-Pay Cancel Counts Table
- **Table:** `rnpc_count_prev_2`
- **Grain:** One row per policy image (`cfxmlid`)
- **Contents:** Non-pay cancel counts for previous 1-5 years and cumulative counts.

### d. Final Billing Variables Table
- **Table:** `BOP_cincibill`
- **Grain:** One row per policy image (`cfxmlid`)
- **Contents:** Policy identifiers, chain ID, evaluation dates, non-pay cancel counts.

## 3. Step-by-Step Process

1. **Extract Distinct Policy IDs**
   - **Input:** Policy lookup staging model
   - **Output:** Unique policy IDs for each LOB.
   - **Purpose:** Identify all unique policies for each LOB.

2. **Build Policy Image Keys**
   - **Input:** Policy IDs, analytic image view staging model
   - **Output:** Policy image details for each policy.
   - **Purpose:** Map each policy to its image details.

3. **Deduplicate Policy Keys**
   - **Input:** Combined policy keys
   - **Output:** Deduplicated set.
   - **Purpose:** Ensure one row per policy image.

4. **Join to Policy Chain Table and Calculate Date Cutoffs**
   - **Input:** Deduplicated policy keys, policy chain staging model
   - **Output:** Policy-chain-date cutoffs.
   - **Purpose:** Attach chain IDs and calculate claim/billing evaluation and cutoff dates.

5. **Map Policies to Billing Accounts**
   - **Input:** Billing policy staging model, policy lookup
   - **Output:** Policy to billing account mapping.
   - **Purpose:** Map policy symbol/number to billing accounts and chain IDs.

6. **Join Policy Chains to Billing Accounts**
   - **Input:** Policy-chain-date cutoffs, billing account mapping
   - **Output:** Policy image with billing account info and existence indicator.

7. **Extract Non-Pay Cancel Transactions**
   - **Input:** Billing activity summary staging model
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

## 4. Recommended dbt Modeling Strategy

### a. Atomic, Testable Models

1. **stg_policy_ids**
   - Extract unique policy IDs from the policy lookup staging model.
   - Test: Uniqueness of policy keys.

2. **stg_policy_images**
   - Map policy IDs to policy image details using analytic image view staging model.
   - Test: No duplicate keys, all expected columns.

3. **stg_policy_chains**
   - Join policy images to chain IDs and calculate evaluation/cutoff dates using the policy chain staging model.
   - Test: Correct join logic, date calculations.

4. **stg_bil_accts**
   - Map policy symbol/number to billing accounts and chain IDs using the billing policy staging model.
   - Test: No duplicate mappings, all expected columns.

5. **int_policy_to_billing**
   - Join policy chains to billing accounts, add existence indicator.
   - Test: Indicator logic, join correctness.

6. **stg_nonpay_cancel_txns**
   - Extract non-pay cancel transactions from billing activity summary staging model.
   - Test: Filter logic, expected columns.

7. **int_nonpay_cancel_counts**
   - Calculate non-pay cancel counts for each policy and period.
   - Test: Correct counts, cumulative logic.

8. **billing_vars_final**
   - Assemble final output table with all required variables.
   - Test: Final grain, all columns, no duplicates.

### b. General Principles

- **Modularization:** Each transformation step as a separate dbt model for clarity and testability.
- **Source Freshness:** Use dbt sources for raw input tables.
- **Testing:** Add dbt tests for uniqueness, not null, relationships, and value ranges.
- **Documentation:** Document each model with descriptions of inputs, outputs, and logic.
- **Parameterization:** Use dbt variables or macros for LOB-specific logic to avoid code duplication.

---

This outline provides a clear, testable path for converting the SAS workflow into a robust, modular dbt project using the appropriate dbt staging models as sources.
