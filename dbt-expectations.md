# DBT Expectations Analysis Report

This document outlines the current state of dbt tests in the project, focusing on `dbt-expectations` (and other generic dbt tests found in the schema files), and provides recommendations for improvement.

## 1. Models and Column Tests

Below is a breakdown of each model, its columns, existing tests, untested columns, and recommendations for additional tests.

---

### Directory: `bop_modeling_data/models/00_raw/billing/`

#### Model: `raw__screngn__xcd_bil_account`
*   **Description:** Raw model for billing account table.
*   **Columns:**
    *   `bil_account_id` (varchar)
        *   Currently Tested: None
        *   Untested
        *   Recommendations:
            *   `dbt_expectations.expect_column_values_to_not_be_null`
            *   `dbt_expectations.expect_column_values_to_be_unique` (if it's a primary key)
            *   `dbt_expectations.expect_column_values_to_match_regex` (if there's a known format)
            *   `dbt_expectations.expect_column_value_lengths_to_be_between` (if has known length constraints)
    *   `bil_account_id_hash` (bigint)
        *   Currently Tested: None
        *   Untested
        *   Recommendations:
            *   `dbt_expectations.expect_column_values_to_not_be_null`
            *   `dbt_expectations.expect_column_values_to_be_unique` (if derived from a unique key)
    *   `BIL_ACCOUNT_NBR` (bigint)
        *   Currently Tested: None
        *   Untested
        *   Recommendations:
            *   `dbt_expectations.expect_column_values_to_not_be_null` (if applicable)
            *   `dbt_expectations.expect_column_values_to_be_of_type: column_type: bigint`
    *   `BIL_CLASS_CD` (varchar)
        *   Currently Tested: None
        *   Untested
        *   Recommendations:
            *   `dbt_expectations.expect_column_values_to_be_in_set` (if known codes)
            *   `dbt_expectations.expect_column_values_to_not_be_null` (if applicable)
            *   `dbt_expectations.expect_column_value_lengths_to_equal` (if it's a fixed-length code)
            *   `dbt_expectations.expect_column_values_to_have_consistent_casing` (if casing matters)
    *   ... (Other columns in `raw__screngn__xcd_bil_account` follow a similar pattern: all are currently untested at the column level in the schema)
    *   **General Recommendation for `raw__screngn__xcd_bil_account`:** For all key/ID columns, add `dbt_expectations.expect_column_values_to_not_be_null` and `dbt_expectations.expect_column_values_to_be_unique` tests. For code columns (`_CD`), use `dbt_expectations.expect_column_values_to_be_in_set`, `dbt_expectations.expect_column_value_lengths_to_equal` (if fixed-length), and `dbt_expectations.expect_column_values_to_have_consistent_casing`. For date columns that are actual date types (`_DT`), use `dbt_expectations.expect_column_values_to_be_of_type: column_type: date`. If they are strings representing dates, use `dbt_expectations.expect_column_values_to_match_regex` with an appropriate pattern (e.g., for 'YYYY-MM-DD'). For timestamp columns (`_TS`), use `dbt_expectations.expect_column_values_to_be_of_type: column_type: timestamp`. For amounts (`_AMT`), consider `dbt_expectations.expect_column_values_to_be_of_type: column_type: double` (or `numeric`) and potentially range checks using `dbt_expectations.expect_column_values_to_be_between`.

#### Model: `raw__screngn__xcd_bil_act_summary`
*   **Description:** Raw model for billing activity summary.
*   **Columns:** `BIL_ACCOUNT_ID`, `BIL_ACY_DT`, `BIL_ACY_SEQ`, `POL_SYMBOL_CD`, `POL_NBR`, `BIL_ACY_DES_CD`, `BIL_DES_REA_TYP`, `BIL_ACY_DES1_DT`, `BIL_ACY_DES2_DT`, `BIL_ACY_AMT`, `USER_ID`, `BIL_ACY_TS`, `BAS_ADD_DATA_TXT`, `bil_account_id_hash`
    *   All columns are currently untested at the column level in the schema.
    *   **Recommendations:** Similar to `raw__screngn__xcd_bil_account`.
        *   Apply `dbt_expectations.expect_column_values_to_not_be_null` and `dbt_expectations.expect_column_values_to_be_unique` (or `dbt_expectations.expect_compound_columns_to_be_unique` for composite keys like `BIL_ACCOUNT_ID`, `BIL_ACY_DT`, `BIL_ACY_SEQ`).
        *   For `BIL_ACY_DT`, `BIL_ACY_DES1_DT`, `BIL_ACY_DES2_DT`: `dbt_expectations.expect_column_values_to_be_of_type: column_type: date` (or `dbt_expectations.expect_column_values_to_match_regex` if string).
        *   For `BIL_ACY_TS`: `dbt_expectations.expect_column_values_to_be_of_type: column_type: timestamp`.
        *   For `BIL_ACY_AMT`: `dbt_expectations.expect_column_values_to_be_of_type: column_type: double` (or `numeric`), `dbt_expectations.expect_column_values_to_be_between` (for range).
        *   For `POL_SYMBOL_CD`, `BIL_ACY_DES_CD`, `BIL_DES_REA_TYP`: `dbt_expectations.expect_column_values_to_be_in_set` (for known codes), `dbt_expectations.expect_column_value_lengths_to_equal` (if fixed-length), `dbt_expectations.expect_column_values_to_have_consistent_casing`.
        *   For `USER_ID`, `BAS_ADD_DATA_TXT`: `dbt_expectations.expect_column_values_to_not_be_null` (if applicable), `dbt_expectations.expect_column_value_lengths_to_be_between`.

#### Model: `raw__screngn__xcd_bil_cash_dsp`
*   **Description:** Raw model for billing cash deposit.
*   **Columns:** `BIL_ACCOUNT_ID`, `BIL_DTB_DT`, `BIL_DTB_SEQ_NBR`, ..., `bil_account_id_hash`
    *   All columns are currently untested.
    *   **Recommendations:** Similar to above. Focus on keys, dates, amounts, and codes.

#### Model: `raw__screngn__xcd_bil_cash_receipt`
*   **Description:** Raw model for billing cash receipt.
*   **Columns:** `BIL_ACCOUNT_ID`, `BIL_DTB_DT`, `BIL_DTB_SEQ_NBR`, ..., `bil_account_id_hash`
    *   All columns are currently untested.
    *   **Recommendations:** Similar to above.

#### Model: `raw__screngn__xcd_bil_des_reason`
*   **Description:** Raw model for billing description reason.
*   **Columns:** `BIL_DES_REA_CD`, `BIL_DES_REA_TYP`, `PRI_LGG_CD`, `BIL_DES_REA_DES`, `BDR_LONG_DES`, `BIL_ACT_BAL_SUM_CD`
    *   All columns are currently untested.
    *   **Recommendations:**
        *   For code columns (`BIL_DES_REA_CD`, `BIL_DES_REA_TYP`, `PRI_LGG_CD`, `BIL_ACT_BAL_SUM_CD`): `dbt_expectations.expect_column_values_to_be_in_set`, `dbt_expectations.expect_column_values_to_not_be_null` (if applicable), `dbt_expectations.expect_column_value_lengths_to_equal` (if fixed-length), `dbt_expectations.expect_column_values_to_have_consistent_casing`.
        *   For description columns (`BIL_DES_REA_DES`, `BDR_LONG_DES`): `dbt_expectations.expect_column_value_lengths_to_be_between`, `dbt_expectations.expect_column_values_to_not_be_null` (if applicable).

#### Model: `raw__screngn__xcd_bil_ist_schedule`
*   **Description:** Raw model for billing ist schedule.
*   **Columns:** `BIL_ACCOUNT_ID`, `XCD_POLICY_ID`, `BIL_SEQ_NBR`, ..., `bil_account_id_hash`, `INVOICED` (example, assuming it exists)
    *   All columns are currently untested.
    *   **Recommendations:** Similar to other raw tables; keys (`not_null`, `unique`/`compound_unique`), dates (`type` or `regex`), amounts (`type`, `range`). For boolean-like columns such as `INVOICED` (if it represents Y/N or 0/1): `dbt_expectations.expect_column_values_to_be_in_set: value_set: ['Y', 'N']` (or `[0,1]`).

#### Model: `raw__screngn__xcd_bil_pol_proc_req`
*   **Description:** Raw model for billing policy processing requests.
*   **Columns:** Numerous columns.
    *   All columns are currently untested.
    *   **Recommendations:** Similar to other raw tables.

#### Model: `raw__screngn__xcd_bil_policy_trm`
*   **Description:** Raw model for billing policy term.
*   **Columns:** Numerous columns.
    *   All columns are currently untested.
    *   **Recommendations:** Similar to other raw tables.

#### Model: `raw__screngn__xcd_bil_policy`
*   **Description:** Raw model for billing policy.
*   **Columns:** `BIL_ACCOUNT_ID`, `XCD_POLICY_ID`, `POL_SYMBOL_CD`, ..., `bil_account_id_hash`
    *   All columns are currently untested.
    *   **Recommendations:** Similar to other raw tables.

---

### Directory: `bop_modeling_data/models/00_raw/decfile/`

#### Model: `raw__decfile__sb_aiv_lookup`
*   **Columns:** `placeholder_column`
    *   Currently untested.
    *   **Recommendations:** Replace placeholder. Once actual columns are defined, add `not_null`, `unique`, type, and format tests as appropriate.

#### Model: `raw__decfile__sb_policy_lookup`
*   **Columns:** `placeholder_column`
    *   Currently untested.
    *   **Recommendations:** Replace placeholder and add relevant tests.

#### Model: `raw__decfile__screngn_policy_lookup`
*   **Columns:** `placeholder_column`
    *   Currently untested.
    *   **Recommendations:** Replace placeholder and add relevant tests.

---

### Directory: `bop_modeling_data/models/00_raw/modcom/`

#### Model: `raw__modcom__policy_chain_v3`
*   **Columns:**
    *   `policy_chain_id`
        *   Untested
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`, `dbt_expectations.expect_column_values_to_be_unique`
    *   `placeholder_column`
        *   Untested
        *   Recommendations: Replace placeholder and add relevant tests.

---

### Directory: `bop_modeling_data/models/01_stg/current_cincibill/`

#### Model: `stg__cur_cb__xcd_bil_act_summary`
*   **Columns:**
    *   `billing_acct_key`: `dbt_expectations.expect_column_to_exist` (Note: test listed twice in schema)
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`
    *   `billing_activity_date`: `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`, `dbt_expectations.expect_column_values_to_be_of_type: column_type: date`
    *   `billing_activity_amt`: `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_values_to_be_of_type: column_type: double`
    *   `billing_activity_desc_cd`: `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_values_to_be_in_set` (if known codes)
    *   `policy_sym`: `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_value_lengths_to_be_between` (if symbol has known length constraints, e.g., 2-4 chars), `dbt_expectations.expect_column_values_to_have_consistent_casing`.
    *   `policy_numb`: `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`, `dbt_expectations.expect_column_values_to_be_between: min_value: 0, max_value: 9999999`
    *   `billing_activity_sequence_numb`: `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`
    *   `billing_acct_id`: `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`
    *   `billing_activity_desc_reason_type`: `dbt_expectations.expect_column_to_exist`

#### Model: `stg__cur_cb__xcd_bil_cash_dsp`
*   **Columns:**
    *   `placeholder_column`: Untested. Recommendation: Define column and tests.
    *   `billing_acct_key`: `dbt_expectations.expect_column_to_exist`
    *   `billing_policy_key`: `dbt_expectations.expect_column_to_exist`
    *   `policy_sym`: `dbt_expectations.expect_column_to_exist`
    *   `policy_numb`: `dbt_expectations.expect_column_to_exist`
    *   `policy_eff_date`: `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_values_to_be_of_type: column_type: date`

#### Model: `stg__cur_cb__xcd_bil_policy`
*   **Columns:**
    *   `billing_acct_key`: `dbt_expectations.expect_column_to_exist`
    *   `billing_acct_id`: `dbt_expectations.expect_column_to_exist`
    *   `billing_acct_numb`: `dbt_expectations.expect_column_to_exist`
    *   `policy_sym`: `dbt_expectations.expect_column_to_exist`
    *   `policy_numb`: `dbt_expectations.expect_column_to_exist`
    *   `bil_account_id_hash`: `dbt_expectations.expect_column_to_exist`
    *   `CURRENT_BILLING_PLAN`: Untested.
        *   Recommendations: `dbt_expectations.expect_column_values_to_be_in_set` (if applicable)

#### Model: `stg__cur_cb`
*   **Columns:**
    *   `billing_sb_policy_key`: `dbt_expectations.expect_column_to_exist`
    *   `placeholder_column`: Untested. Recommendation: Define column and tests.
    *   `billing_acct_key`: `dbt_expectations.expect_column_to_exist`
    *   `billing_activity_date`: `dbt_expectations.expect_column_to_exist`
    *   `billing_activity_sequence_numb`: `dbt_expectations.expect_column_to_exist`
    *   `billing_activity_amt`: `dbt_expectations.expect_column_to_exist`
    *   `associated_policy_key`: `dbt_expectations.expect_column_to_exist`
    *   `associated_sb_policy_key`: `dbt_expectations.expect_column_to_exist`
    *   `billing_policy_key`: `dbt_expectations.expect_column_to_exist`

---

### Directory: `bop_modeling_data/models/01_stg/decfile/`

#### Model: `stg__decfile__sb_policy_lookup`
*   **Model-level tests:** `dbt_expectations.expect_table_row_count_to_equal_other_table: compare_model: ref("raw__decfile__sb_policy_lookup")`
*   **Columns:**
    *   `sb_policy_key`: `dbt_expectations.expect_column_values_to_be_unique`, `dbt_expectations.expect_column_values_to_not_be_null`
    *   `policy_chain_id`: `dbt_expectations.expect_column_values_to_not_be_null`
        *   Recommendations: Consider `relationships` test if it's a foreign key to another processed table.
    *   `lob`: `dbt_expectations.expect_column_values_to_not_be_null`, `dbt_expectations.expect_column_values_to_be_in_set: value_set: ['prop', 'liab']`
    *   `company_numb`: `dbt_expectations.expect_column_values_to_not_be_null`, `dbt_expectations.expect_column_values_to_be_in_set: value_set: [1, 3, 5, 7, 4]`, `dbt_expectations.expect_column_values_to_be_between: min_value: 1, max_value: 9`
    *   `policy_sym`: `dbt_expectations.expect_column_values_to_not_be_null`
        *   Recommendations: `dbt_expectations.expect_column_value_lengths_to_be_between` (if symbol has fixed/max length)
    *   `policy_numb`: `dbt_expectations.expect_column_values_to_not_be_null`, `dbt_expectations.expect_column_values_to_be_between: min_value: 0, max_value: 9999999`
    *   `policy_module`: `dbt_expectations.expect_column_values_to_not_be_null`, `dbt_expectations.expect_column_values_to_be_between: min_value: 0, max_value: 999`
    *   `policy_eff_date`: `dbt_expectations.expect_column_values_to_not_be_null`
        *   Recommendations: `dbt_expectations.expect_column_values_to_be_of_type: column_type: date`

---

### Directory: `bop_modeling_data/models/01_stg/modcom/`

#### Model: `stg__modcom__policy_chain_v3`
*   **Columns:**
    *   `policy_chain_id`: `not_null` (generic dbt test)
        *   Recommendations: `dbt_expectations.expect_column_values_to_be_unique` (if it's a primary key for this staging model)
    *   `company_numb`: `not_null`
    *   `policy_sym`: `not_null`
    *   `policy_numb`: `not_null`
    *   `policy_module`: `not_null`
    *   `policy_eff_date`: `not_null`
        *   Recommendations: `dbt_expectations.expect_column_values_to_be_of_type: column_type: timestamp` (or date if appropriate)
    *   `five_key_hash`: Untested
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`, `dbt_expectations.expect_column_values_to_be_unique` (if this hash is intended to be unique)
    *   `three_key_hash`: Untested
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`

---

### Directory: `bop_modeling_data/models/01_stg/screngn/`
*   **General Note:** Models in this directory (`stg__screngn__xcd_bil_account`, `stg__screngn__xcd_bil_act_summary`, etc.) have model-level tests (`dbt_expectations.expect_table_row_count_to_equal_other_table`) comparing them to their raw counterparts. However, column-level tests are not specified in the provided schema snippets.
*   **Recommendation:** For all staging models in this directory, add column-level tests. This includes:
    *   `dbt_expectations.expect_column_values_to_not_be_null` for critical identifiers and attributes.
    *   Type checking (e.g., `dbt_expectations.expect_column_values_to_be_of_type: column_type: date` or `dbt_expectations.expect_column_values_to_be_of_type: column_type: timestamp` or `dbt_expectations.expect_column_values_to_be_of_type: column_type: numeric`).
    *   Format checking for dates if they are strings (e.g., `dbt_expectations.expect_column_values_to_match_regex` with a pattern like `'^\\d{4}-\\d{2}-\\d{2}$'` for YYYY-MM-DD).
    *   `dbt_expectations.expect_column_values_to_be_in_set` for categorical/code columns.
    *   `dbt_expectations.expect_column_value_lengths_to_equal` or `dbt_expectations.expect_column_value_lengths_to_be_between` for string identifiers/codes.
    *   `dbt_expectations.expect_column_values_to_have_consistent_casing` for relevant string columns.
    *   Uniqueness for primary keys (`dbt_expectations.expect_column_values_to_be_unique`) or compound keys (`dbt_expectations.expect_compound_columns_to_be_unique`).
    *   Referential integrity (`relationships` test) if they link to other staging or lookup tables.

---

### Directory: `bop_modeling_data/models/02_lkp/`

#### Model: `lkp__associated_policies`
*   **Model-level tests:** `dbt_expectations.expect_compound_columns_to_be_unique: column_list: [ "associated_policy_key", "associated_sb_policy_key" ]`
*   **Columns:**
    *   `associated_policy_key`: `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`
    *   `associated_sb_policy_key`: `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`, `relationships` test to `lkp__sb_policy_key.sb_policy_key`
    *   `policy_chain_id`: `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`, `relationships` test to `stg__modcom__policy_chain_v3.policy_chain_id`
    *   `company_numb`, `policy_sym`, `policy_numb`, `policy_module`: All have `dbt_expectations.expect_column_to_exist`.
        *   Recommendations: Add `dbt_expectations.expect_column_values_to_not_be_null` for each.
    *   `policy_eff_date`: `dbt_expectations.expect_column_to_exist`, `dbt_expectations.expect_column_values_to_be_of_type: column_type: date`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`.
    *   `__is_gt1_five_key_in_table`: Untested.
        *   Recommendations: `dbt_expectations.expect_column_values_to_be_in_set: value_set: [0, 1]` (assuming boolean-like tinyint), `dbt_expectations.expect_column_values_to_not_be_null`.

#### Model: `lkp__billing_policies`
*   **Columns:**
    *   `billing_sb_policy_key`: `dbt_expectations.expect_column_values_to_be_between: min_value: 0, max_value: 10` (Review this range), `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`, `relationships` test. The `expect_column_values_to_be_between` with `max_value: 10` seems very specific and might warrant a review if "10" is an arbitrary upper bound for a key or if it's a count of something else. If it's a key, uniqueness and not_null are more typical.
    *   `associated_policy_key`: `dbt_expectations.expect_column_to_exist`, `relationships: field: associated_policy_key, to: ref('lkp__associated_policies')`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`.
    *   `billing_acct_key`: `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`.
    *   `billing_policy_key`: `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`.
    *   `associated_sb_policy_key`: `dbt_expectations.expect_column_values_to_be_between: min_value: 0, max_value: 10` (Review this range)
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`, `relationships` test. Review range as above.
    *   `billing_policy_id`, `billing_acct_id`, `policy_sym`, `policy_numb`, `policy_eff_date`: Untested.
        *   Recommendations: `not_null` for IDs and dates. Type check for date.

#### Model: `lkp__dates`
*   **Model-level tests:** `dbt_utils.expression_is_true: expression: 'prior_year_end >= prior_year_start'`
*   **Columns:** `input_date`, `n_prior_years`, `prior_year_start`, `prior_year_end`: All have `dbt_expectations.expect_column_to_exist`.
    *   Recommendations: Add `dbt_expectations.expect_column_values_to_not_be_null` for all. Type checks (`date` for date columns, `integer` for `n_prior_years`).

#### Model: `lkp__first_billing_activity_date`
*   **Columns:**
    *   `activity_trans_key`: `dbt_expectations.expect_column_to_exist`, `relationships: to: ref('fct__billing_activity'), field: activity_trans_key`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`, `dbt_expectations.expect_column_values_to_be_unique` (if this is the PK of this lookup).
    *   `first_billing_activity_date`: `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`, `dbt_expectations.expect_column_values_to_be_of_type: column_type: date`.

#### Model: `lkp__policy_chain_ids`
*   **Columns:**
    *   `policy_chain_id`: `dbt_expectations.expect_column_to_exist`, `relationships: to: ref('stg__decfile__sb_policy_lookup'), field: policy_chain_id`, `relationships: to: ref('stg__modcom__policy_chain_v3'), field: policy_chain_id`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`, `dbt_expectations.expect_column_values_to_be_unique` (as it's the key of this lookup).
    *   `n_sb_policies_for_policy_chain_id`, `n_total_policies_for_policy_chain_id`: Both have `dbt_expectations.expect_column_values_to_be_between: min_value: 0, max_value: 10` (Review this range) and `dbt_expectations.expect_column_to_exist`.
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`. The range `0-10` seems very restrictive for counts; verify if this is correct or if a more general `dbt_expectations.expect_column_values_to_be_between: min_value: 0` is sufficient.

#### Model: `lkp__sb_policy_key`
*   **Columns:**
    *   `sb_policy_key`: `dbt_expectations.expect_column_values_to_be_between: min_value: 0, max_value: 10` (Review this range), `dbt_expectations.expect_column_to_exist`, `dbt_expectations.expect_column_values_to_be_unique`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`. Review the `expect_column_values_to_be_between` range.
    *   `policy_chain_id`, `lob`, `company_numb`, `policy_sym`, `policy_numb`, `policy_module`, `policy_eff_date`: All have `dbt_expectations.expect_column_to_exist`. `lob` also has `expect_column_values_to_be_in_set`.
        *   Recommendations: Add `dbt_expectations.expect_column_values_to_not_be_null` for all. Type check for `policy_eff_date`.

---

### Directory: `bop_modeling_data/models/03_fct/`

#### Model: `fct__associated_policy_eff_date`
*   **Columns:** `associated_policy_key`, `policy_eff_date`, `n_prior_years`, `prior_year_start`, `prior_year_end`: All have `dbt_expectations.expect_column_to_exist`.
    *   Recommendations: Add `dbt_expectations.expect_column_values_to_not_be_null` for all. Type checks for dates and integer. `relationships` for `associated_policy_key`.

#### Model: `fct__billing_activity`
*   **Columns:**
    *   `activity_trans_key`: `dbt_expectations.expect_column_to_exist`, `dbt_expectations.expect_column_proportion_of_unique_values_to_be_between: min_value: 0.5, max_value: 1.0`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`, `dbt_expectations.expect_column_values_to_be_unique` (if it's the primary key).
    *   `associated_policy_key`: `dbt_expectations.expect_column_to_exist`, `relationships: field: associated_policy_key, to: ref('lkp__associated_policies')`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`.
    *   `associated_sb_policy_key`: `dbt_expectations.expect_column_to_exist`, `relationships: field: associated_sb_policy_key, to: ref('lkp__associated_policies')`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`.
    *   `billing_activity_date`: `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_values_to_not_be_null`, `dbt_expectations.expect_column_values_to_be_of_type: column_type: date`, `dbt_expectations.expect_row_values_to_have_recent_data` (if applicable for the fact table).
    *   `billing_activity_amt`: `dbt_expectations.expect_column_to_exist`
        *   Recommendations: `dbt_expectations.expect_column_values_to_be_of_type: column_type: numeric` (or `double`), `dbt_expectations.expect_column_mean_to_be_between` (if there are expected averages).

#### Model: `fct__prior_activity_dates`
*   **Columns:** `activity_trans_key`, `billing_activity_date`, `policy_eff_date`, `eval_date`, `prev_1yr_start` to `prev_5yr_start`, `prev_1yr_end` to `prev_5yr_end`: All have `dbt_expectations.expect_column_to_exist`.
    *   Recommendations: Add `dbt_expectations.expect_column_values_to_not_be_null` for all key and date columns. `dbt_expectations.expect_column_values_to_be_of_type: column_type: date` for all date columns. `relationships` for `activity_trans_key`. Consider `dbt_expectations.expect_column_pair_values_A_to_be_greater_than_B` (e.g. `prev_1yr_end` > `prev_1yr_start`).

---

### Directory: `bop_modeling_data/models/05_mrt/`

#### Model: `dm__npc_counts`
*   **Note:** Column tests are commented out in the schema file. Effectively, no column tests are active.
*   **Columns (from commented section):** `sb_policy_key`, `policy_chain_id`, `policy_eff_date`, `prior_yr1_c_activity_count`, `prior_yr1_c_activity_amount_sum`, ..., `prior_yr5_c_activity_amount_sum`.
*   **Recommendations:**
    *   Uncomment the existing tests if they are still relevant.
    *   For `sb_policy_key`, `policy_chain_id`: Add `dbt_expectations.expect_column_values_to_not_be_null`, `relationships` tests.
    *   For `policy_eff_date`: Add `dbt_expectations.expect_column_values_to_not_be_null`, `dbt_expectations.expect_column_values_to_be_of_type: column_type: date`, `dbt_expectations.expect_row_values_to_have_recent_data` (if applicable to the mart's refresh cycle).
    *   Consider `dbt_expectations.expect_compound_columns_to_be_unique: column_list: ["sb_policy_key", "policy_eff_date"]` (or similar, depending on grain).
    *   For count columns (`_count`): Add `dbt_expectations.expect_column_values_to_be_of_type: column_type: integer` (or appropriate numeric type), `dbt_expectations.expect_column_values_to_be_between: min_value: 0`.
    *   For amount sum columns (`_amount_sum`): Add `dbt_expectations.expect_column_values_to_be_of_type: column_type: numeric` (or `double`/`decimal`), consider `dbt_expectations.expect_column_mean_to_be_between` or `dbt_expectations.expect_column_sum_to_be_between` if there are expected ranges for these aggregates.

---

## 2. Other Notes and Comments

*   **Raw Layer Testing:** The `00_raw` models currently have no column-level tests defined in their schemas. While raw data can be unpredictable, basic tests like `expect_column_to_exist` (which is implicitly handled by dbt if columns are listed) and perhaps `expect_column_values_to_not_be_null` for absolutely critical source identifiers could be beneficial. More advanced raw data profiling might be done with `dbt_profiler` initially, then codifying some expectations.
*   **Staging Layer Testing:** The `01_stg` layer shows a good start with some `dbt_expectations` usage, especially for type casting, renaming, and basic existence. The `stg__screngn` models rely on model-level row count checks but lack column-level specifics in the schema. This is a key area for enhancement.
*   **Lookup (lkp) Layer Testing:** This layer has a more consistent use of `dbt_expectations`, including `relationships` tests, uniqueness, and value set checks. Some `min_to_be_between` tests with a max of 10 for keys/counts seem unusually restrictive and might need review.
*   **Fact (fct) Layer Testing:** Good use of `expect_column_to_exist` and some `relationships` tests. Can be enhanced with more `not_null` and type checks.
*   **Mart (mrt) Layer Testing:** The `dm__npc_counts` model has its tests commented out. These should be reviewed and enabled. Marts are critical for end-users, so robust testing here is vital.
*   **Placeholder Columns:** Several schemas (`00_raw/decfile`, `00_raw/modcom`, `01_stg/current_cincibill`) contain `placeholder_column`. These should be resolved with actual column definitions and tests.
*   **Consistency:** While `dbt_expectations` is used, the depth and breadth vary. Aim for a consistent baseline of tests for similar column types across layers (e.g., all primary keys should be `not_null` and `unique`).
*   **`dbt_utils.expression_is_true`:** Used in `lkp__dates`, which is good for custom logic checks.
*   **Test Naming & Duplication:** In `stg__cur_cb__xcd_bil_act_summary`, `billing_acct_key` has `dbt_expectations.expect_column_to_exist` listed twice. This should be cleaned up.
*   **Prerequisites for `dbt-expectations`:** To effectively use the recommended `dbt-expectations` tests, ensure the package is correctly installed in your `packages.yml` file and any necessary variables (e.g., `'dbt_date:time_zone'`) are configured in your `dbt_project.yml` file, as detailed in the `dbt-expectations-docs.md` or the official package documentation.

## 3. Summary of the Project

*   **Current State:** The project has a foundational set of dbt tests, with `dbt-expectations` being utilized in several layers, particularly lookups and staging tables. There's evidence of thoughtful testing strategies like row count comparisons between layers and referential integrity checks.
*   **Strengths:**
    *   Use of `dbt-expectations` for common data quality checks.
    *   Application of `relationships` tests for foreign key integrity.
    *   Model-level tests for row count validation.
    *   Specific value set and range checks in some models.
*   **Areas for Improvement:**
    *   **Comprehensive Raw/Staging Tests:** Raw and some staging models lack detailed column-level tests. Basic non-null, type, and format checks would improve data quality early in the pipeline.
    *   **Activate Mart Tests:** Tests for the `dm__npc_counts` mart are currently disabled and should be a priority to enable.
    *   **Resolve Placeholders:** Placeholder columns need to be defined and tested.
    *   **Consistency:** Standardize the baseline tests applied to common column types (IDs, dates, codes, amounts) across all relevant models.
    *   **Review Restrictive Tests:** Some range tests (e.g., `max_value: 10` for counts/keys) should be reviewed for correctness.
    *   **Leverage More Expectations:** Explore more `dbt-expectations` tests for richer data validation. Refer to the `dbt-expectations-docs.md` or the official package documentation for a comprehensive list and usage details. Examples include:
        *   `dbt_expectations.expect_column_values_to_match_regex` for specific string patterns.
        *   `dbt_expectations.expect_column_values_to_be_increasing` or `dbt_expectations.expect_column_values_to_be_decreasing` for sequence/date logic.
        *   `dbt_expectations.expect_multicolumn_sum_to_equal` for financial data validation.
        *   `dbt_expectations.expect_table_row_count_to_be_between` for table-level row count validations.
        *   `dbt_expectations.expect_column_value_lengths_to_be_between` for string length checks.
        *   `dbt_expectations.expect_column_distinct_count_to_equal` for distinct value counts in a column.
        *   `dbt_expectations.expect_column_values_to_have_consistent_casing` for case consistency.
        *   `dbt_expectations.expect_column_mean_to_be_between` for checking the mean of a column.
        *   `dbt_expectations.expect_row_values_to_have_recent_data` for data freshness.

By addressing these areas, the project can significantly enhance its data reliability and the trustworthiness of its analytical outputs.
