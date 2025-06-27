# Credit Model SAS-to-dbt Conversion Outline

## 1. Inputs

### a. Rerated Premium Tables
- **Tables:** `rerated_prop`, `rerated_gl`
- **Grain:** One row per policy (identified by `cfxmlid`, `historical_company`, `policysymbol`, `policynumber`, `statisticalpolicymodulenumber`, `policyeffectivedate`, etc.)
- **Purpose:** Provide the set of policies to process for each line of business (Prop, GL).

### b. Experian Data Table
- **Table:** `ACTCOV51.&exp_data.`
- **Grain:** One row per policy snapshot (joined on company, policy symbol/number, effective date, etc.)
- **Purpose:** Supplies credit-related variables (BIN, Intelliscore, trades, balances, judgments, liens, bankruptcies, etc.) for each policy.

### c. Summary/Imputation Table
- **Table:** `my_mosum.&LOB._se_vars`
- **Grain:** One row per policy (`cfxmlid`)
- **Purpose:** Provides median or default values for imputation when Experian data is missing.

## 2. Outputs

### a. Final Credit Variables Table
- **Table:** `my_exp.&LOB._credit_vars_Final`
- **Grain:** One row per policy (`cfxmlid`)
- **Contents:** 
  - Policy identifiers
  - Experian snapshot variables
  - Calculated and imputed credit score variables
  - Source/indicator flags for imputation
  - Derived/capped/normalized variables

## 3. Step-by-Step Process

1. **Extract Distinct Policies**
   - **Input:** Rerated premium table for the LOB
   - **Output:** Table of unique policies (`&LOB._pols`)
   - **Purpose:** Identify all policies to process for the current LOB.

2. **Join with Experian Data and Imputation Table**
   - **Input:** Policies (`&LOB._pols`), Experian data, imputation table
   - **Output:** Table with all raw, calculated, and imputed variables (`&LOB._credit_vars`)
   - **Purpose:** 
     - Join policies to Experian data (complex join on company, policy symbol/number, effective date).
     - Join to imputation table for missing value handling.
     - Calculate:
       - Hit flags (BIN, Intelliscore)
       - Raw Experian variables
       - Derived variables (positive-value indicators, ratios, normalized/capped values)
       - Imputed variables (using coalesce/median/defaults)
       - Source flags for imputation
       - Credit score (log and exponentiated), with imputed versions

3. **Sort and Deduplicate**
   - **Input:** Credit variables table (`&LOB._credit_vars`)
   - **Output:** Sorted table (`&LOB._credit_vars_Sorted`)
   - **Purpose:** Ensure records are ordered for deduplication.

4. **Select First BIN per Policy**
   - **Input:** Sorted credit variables table
   - **Output:** Final table with one row per policy (`my_exp.&LOB._credit_vars_Final`)
   - **Purpose:** For policies with multiple BINs, keep only the first.

5. **Cleanup Temporary Tables**
   - **Input:** All intermediate tables
   - **Purpose:** Remove temp tables to keep workspace clean.

6. **Repeat for Each LOB**
   - **Input:** Prop and GL rerated tables
   - **Purpose:** Run the above steps for both lines of business.

## 4. Recommended dbt Modeling Strategy

### a. Atomic, Testable Models

1. **stg_policy_identifiers**
   - Extract unique policies from rerated tables for each LOB.
   - Test: Uniqueness of policy keys.

2. **stg_experian_snapshot**
   - Standardize Experian data for joining.
   - Test: No duplicate keys, expected columns present.

3. **stg_imputation_values**
   - Prepare imputation/median/default values per policy.
   - Test: No duplicate cfxmlid, all required imputation columns present.

4. **int_credit_vars_joined**
   - Join policies to Experian and imputation tables.
   - Calculate all raw, derived, and imputed variables.
   - Test: All expected columns, correct join logic, imputation logic.

5. **int_credit_vars_sorted**
   - Sort and deduplicate to one row per policy.
   - Test: Only one row per cfxmlid.

6. **credit_vars_final**
   - Final selection and output.
   - Test: Final grain, all required columns, no duplicates.

### b. General Principles

- **Modularization:** Each transformation step as a separate dbt model for clarity and testability.
- **Source Freshness:** Use dbt sources for raw input tables.
- **Testing:** Add dbt tests for uniqueness, not null, relationships, and value ranges.
- **Documentation:** Document each model with descriptions of inputs, outputs, and logic.
- **Parameterization:** Use dbt variables or macros for LOB-specific logic to avoid code duplication.

---

This outline provides a clear, testable path for converting the SAS macro-based workflow into a robust, modular dbt project.
