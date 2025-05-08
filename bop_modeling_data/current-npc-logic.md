# Analysis of `current_npc_logic.sas`

This document provides a step-by-step analysis of the `current_npc_logic.sas` script. The script calculates Non-Payment Cancellation (NPC) counts for policies. The primary grain of the final output is `cfxmlid`, which represents a specific policy image.

**Note on Date Fields:** The SAS script frequently uses `imageeffectivedate`. For the purpose of replicating this logic in dbt, this field should be considered equivalent to `policyeffectivedate`.

**Note on `cfxmlid`:** The script operates at the policy level, even though `cfxmlid` is a unique identifier for policy images. In dbt, we will generally use `sb_policy_key` when referencing `cfxmlid`.

**Note on constructing full policy keys:** The script uses `cfxmlid` to join with other tables to retrieve full policy keys. In dbt, we will use the `sb_policy_key` for this purpose. Since `sb_policy_key` is given in the `lkp__sb_policy_key` model, along with the fields it uniquely defines, some of the inital data processing steps in the script can be skipped in dbt.

**Note on policy_chain_by_s2n:** The script uses a lookup table `common.lkup_policy_chain_by_s2n` to map the first two characters from a policy symbol and the full number to their respective policy chains. In dbt, we will instead use the policy chain ID directly from the `sb_policy_key` table, which is already linked to the policy chain.

## 1. Identify Policy Images from Rerated Data

The script begins by identifying unique `cfxmlid` values from property and general liability rerated datasets.

*   **`Prop_Cfxs` Table:**
    *   **Source:** `Exps_Raw.&prop_rerated_raw.` (a macro variable indicates the source table name for property rerated data).
    *   **Logic:** Selects distinct `cfxmlid` values.
    *   **Purpose:** To get a list of unique identifiers for property policy images that have been rerated.
    *   **Note:** This step is already handled by the creation of the `sb_policy_key` in an upstream process, so we can skip this in dbt.

*   **`GL_Cfxs` Table:**
    *   **Source:** `Exps_Raw.&gl_rerated_raw.` (a macro variable indicates the source table name for general liability rerated data).
    *   **Logic:** Selects distinct `cfxmlid` values.
    *   **Purpose:** To get a list of unique identifiers for general liability policy images that have been rerated.
    *   **Note:** This step is already handled by the creation of the `sb_policy_key` in an upstream process, so we can skip this in dbt.


## 2. Construct Full Policy Keys for Identified CFXMLIDs

This section fetches detailed policy key information for the `cfxmlid`s gathered in the previous step.

*   **`work.prop_cfxml_pol_keys` Table:**
    *   **Sources:** `Prop_Cfxs` (from step 1) and `smbizhal.&prop_ev.` (property policy event/header data).
    *   **Logic:** Left joins `Prop_Cfxs` (aliased `a`) with `smbizhal.&prop_ev.` (aliased `b`) on `a.cfxmlid = b.cfxmlid`.
    *   **Selected Fields:** `cfxmlid`, `companycode`, `policysymbol`, `policynumber`, `policyeffectivedate`, `statisticalpolicymodulenumber`, `imageeffectivedate`, `imageexpirationdate`. Dates are formatted.
    *   **Purpose:** To retrieve detailed policy key information for the property `cfxmlid`s.
    *   **Note:** This step is already handled by the creation of the `sb_policy_key` in an upstream process, so we can skip this in dbt.


*   **`work.gl_cfxml_pol_keys` Table:**
    *   **Sources:** `GL_Cfxs` (from step 1) and `smbizhal.&gl_ev.` (GL policy event/header data).
    *   **Logic:** Similar left join as above for GL policies.
    *   **Purpose:** To retrieve detailed policy key information for the GL `cfxmlid`s.
    *   **Note:** This step is already handled by the creation of the `sb_policy_key` in an upstream process, so we can skip this in dbt.


*   **`work.cfxml_pol_keys` Data Step:**
    *   **Sources:** `work.prop_cfxml_pol_keys`, `work.gl_cfxml_pol_keys`.
    *   **Logic:** Appends the two datasets together.
    *   **Purpose:** To create a combined dataset of all policy keys.
    *   **Note:** This step is already handled by the creation of the `sb_policy_key` in an upstream process, so we can skip this in dbt.


*   **`cfxml_pol_keys` Table (Sorted & Deduplicated):**
    *   **Source:** `work.cfxml_pol_keys`.
    *   **Logic:** Sorts the data by `cfxmlid` and removes duplicate rows based on `cfxmlid` (`nodupkey`).
    *   **Purpose:** To create a unique list of policy images (keyed by `cfxmlid`) with their associated key components.
    *   **Note:** This step is already handled by the creation of the `sb_policy_key` in an upstream process, so we can skip this in dbt and instead reference the `lkp__sb_policy_key` model directly.


## 3. Create `cfxml_pols_chains_cutoffs` Table: Linking Policies to Chains and Defining Date Cutoffs

This is a crucial step in the SAS process where policy images are linked to policy chains, and various date cutoffs for claim and billing analysis are calculated. However it is important to realize that the `lkp__sb_policy_key` model already contains the `policy_chain_id` for each policy, so this is likely not needed in dbt.

Instead, it is enough to select the `policy_chain_id` from the `lkp__sb_policy_key` model and use that obtain the associated policies from the `stg__modcom__policy_chain_v3` model.

*   **Source Tables:**
    *   `cfxml_pol_keys` (aliased `t1`, created in step 2).
    *   `ACTCOLIB.POLICY_CHAIN_V3` (aliased `t2`, a policy chain lookup table).
*   **Join Logic (t1 Left Join t2):**
    *   Links `cfxml_pol_keys` to `POLICY_CHAIN_V3` to fetch `policy_chain_id`.
    *   The join conditions map fields from `t1` to `t2`:
        *   `companycode` is mapped to `COMPANY_NUMB` (e.g., 'CID' to 3, 'CIC' to 5, 'CCC' to 7).
        *   `policysymbol` to `POLICY_SYM`.
        *   `policynumber` (converted from character to numeric) to `POLICY_NUMB`.
        *   `policyeffectivedate` to `POLICY_EFF_DATE`.
        *   `statisticalpolicymodulenumber` (converted from character to numeric) to `POLICY_MODULE`.
*   **Calculated Date Fields (based on `t1.imageeffectivedate`, which will be `t1.policyeffectivedate` in dbt):**
    *   **Claim-Related Dates (for context, not directly used in final NPC counts in this script):**
        *   `clm_eval_date`: `intnx('month', t1.imageeffectivedate, -4, 's')` (Evaluation date is 4 months prior to image effective date, same day).
        *   `clm_prev_1yr_start`: `intnx('month', clm_eval_date, -8, 's')` (Start of 1st prior claim year: 8 months prior to `clm_eval_date`, effectively 12 months prior to `imageeffectivedate`).
        *   `clm_prev_1yr_end`: `clm_eval_date`.
        *   Similar patterns for `clm_prev_2yr_start/end` through `clm_prev_5yr_start/end`, defining rolling 12-month windows for claims analysis, offset by the initial 4-month lag.
    *   **Billing-Related Dates (Critical for NPC Counts):**
        *   `bil_eval_date`: `intnx('month', t1.imageeffectivedate, -4, 's')` (Billing evaluation date: 4 months prior to image effective date, same day). This date acts as the end boundary for the "1st prior year" of billing activity lookback.
        *   `bil_prev_1yr_start`: `intnx('year', t1.imageeffectivedate, -1, 's')` (Start of 1st prior billing year: 1 year prior to image effective date, same day).
        *   `bil_prev_1yr_end`: `bil_eval_date`.
            *   **Window 1:** `[t1.imageeffectivedate - 1 year, t1.imageeffectivedate - 4 months)`
        *   `bil_prev_2yr_start`: `intnx('year', t1.imageeffectivedate, -2, 's')`.
        *   `bil_prev_2yr_end`: `bil_prev_1yr_start` (which is `t1.imageeffectivedate - 1 year`).
            *   **Window 2:** `[t1.imageeffectivedate - 2 years, t1.imageeffectivedate - 1 year)`
        *   This pattern continues for `bil_prev_3yr`, `bil_prev_4yr`, and `bil_prev_5yr`, creating contiguous 12-month lookback windows after the first 8-month window.
*   **Output:** The table `cfxml_pols_chains_cutoffs` contains one row per `cfxmlid` (if a chain match is found), including its policy keys, `policy_chain_id`, and all the calculated claim and billing date cutoffs.
*   **Order By:** `input(scan(t1.cfxmlid,2,'.'),9.), input(scan(t1.cfxmlid,3,'.'),4.)` (ordering based on numeric parts of `cfxmlid`). Since we are primarily focusing on `sb_policy_key` in dbt, this ordering is not directly relevant, and we can omit it in our dbt model.
*   **Note:** The `intnx` function is used to calculate date intervals. In dbt, we can use the `date_trunc` and `date_add` functions to achieve similar results.

## 4. Delete Intermediate Work Tables

*   **Logic:** `proc datasets lib=work nolist; delete prop_cfxml_pol_keys gl_cfxml_pol_keys cfxml_pol_keys; quit;`
*   **Purpose:** Cleans up temporary tables created in step 2.
*   **Note:** This is a common practice in SAS to free up resources and keep the workspace tidy, but we do not need to replicate this in dbt as it handles intermediate tables differently.

## 5. CinciBill Table Processing: Linking Policies to Billing Accounts via Policy Chains

This section aims to identify the `bil_account_id` associated with the policy chains of the initial `cfxmlid`s.
**Note on dbt Implementation:** As per project notes, the dbt equivalent of this step will not use a direct analog of `common.lkup_policy_chain_by_s2n`. Instead, it's assumed that policies referenced in the billing data (`screngn.xcd_bil_policy`) can have their `policy_chain_id` determined by matching their partial key components (symbol, number, and effective date--excludes company and module) against the main policy chain definition table (`ACTCOLIB.POLICY_CHAIN_V3` or its dbt equivalent `stg__modcom__policy_chain_v3`). The `policy_chain_id` for the target `sb_policy_key` (the `cfxmlid` equivalent) is already known from `lkp__sb_policy_key`.

*   **`pol_s2n_acct` Table:**
    *   **Source:** `screngn.xcd_bil_policy` (billing policy table).
    *   **Logic:** Selects distinct `bil_account_id`, `bil_account_nbr`. Crucially, for dbt replication, this step would also need to extract the full policy key components (e.g., company code, policy symbol, policy number, policy module, and the effective date of the policy term as referenced in the billing system) from `screngn.xcd_bil_policy`.
    *   **Purpose:** To get a mapping of billing account IDs to the full policy identifiers of policies covered by those accounts.

*   **`s2n_acct_to_chn_closure_step1` Table:**
    *   **Sources:** `pol_s2n_acct` (aliased `t1`, now containing full policy key components from `xcd_bil_policy`) and `ACTCOLIB.POLICY_CHAIN_V3` (aliased `t2`, the main policy chain definition table).
    *   **Logic:** Left joins `t1` to `t2` using the full policy key components (company, symbol, number, module, effective date) to look up the `policy_chain_id`.
    *   **Purpose:** To associate each `bil_account_id` (from `xcd_bil_policy`) with a `policy_chain_id` by matching the policy details from the billing record to the comprehensive policy chain data. This bypasses the need for the `common.lkup_policy_chain_by_s2n` lookup.

*   **`all_bil_acct_for_s2n` Table:**
    *   **Sources:** `s2n_acct_to_chn_closure_step1` (aliased `t1`, which now has `bil_account_id`, `policy_chain_id`) and `ACTCOLIB.POLICY_CHAIN_V3` (aliased `t2`).
    *   **Logic:** Left joins `t1` to `t2` on `t1.policy_chain_id = t2.policy_chain_id`.
    *   **Purpose:** To find all policy key components (from `t2`) that belong to the same `policy_chain_id` already associated with a `bil_account_id`. This effectively links a `bil_account_id` to all policies (identified by their full keys) within its chain, using the main policy chain table as the source for these policy details.

## 6. Commented Out `ADD_DATE_CUTOFFS_2` Table Creation

*   The script contains a commented-out `proc sql` block intended to create a table named `ADD_DATE_CUTOFFS_2`. This section is not executed. It appears to be an alternative or older version for generating date cutoffs similar to those in `cfxml_pols_chains_cutoffs`.

## 7. `init_inforce_to_cinbil_acct` Table: Linking CFXMLIDs to Billing Accounts

This step connects the initial set of policies (with their date cutoffs) to the billing account IDs derived through their policy chains.

*   **Sources:**
    *   `cfxml_pols_chains_cutoffs` (aliased `t1`, from step 3).
    *   `all_bil_acct_for_s2n` (aliased `t2`, from step 5).
*   **Logic:** Left joins `t1` to `t2` on `t1.policy_chain_id = t2.policy_chain_id`.
*   **Selected Fields:** Includes all fields from `t1` (policy details, chain ID, date cutoffs) and `t2.bil_account_id`, `t2.bil_account_nbr`.
*   **`cinbill_acct_by_chain_exists_ind`:** Calculated as `max(not missing(t2.bil_account_id))`. This flag is 1 if a `bil_account_id` was found for the policy's chain, 0 otherwise (after group by).
*   **Group By:** `t1.cfxmlid`. This implies that if a `cfxmlid`'s chain links to multiple billing accounts, one will be chosen based on the `max` function (though `bil_account_id` is not in an aggregate, this is typical SAS behavior in `PROC SQL` when `GROUP BY` is used with non-aggregated columns not in the `GROUP BY` - it usually takes values from the first record in the group). However, the `distinct` in `all_bil_acct_for_s2n` might make this less of an issue if `(policy_chain_id, bil_account_id)` is unique there.
*   **Purpose:** To associate each `cfxmlid` with a relevant `bil_account_id` (if one exists via its policy chain) and the pre-calculated date cutoffs.

## 8. `rnpc_all` Table: Identifying Raw NPC Events

This table extracts all billing activities that are considered Non-Payment Cancellations.

*   **Source:** `screngn.xcd_bil_act_summary` (billing activity summary table).
*   **Selected Fields:** `bil_account_id`, `bil_acy_dt` (activity date), `bil_acy_seq` (activity sequence), `bil_acy_amt` (activity amount), `pol_symbol_2` (derived), `pol_nbr` (derived).
*   **Filtering Condition (Crucial for NPC Definition):**
    *   `where bil_acy_des_cd = 'C' and bil_des_rea_typ = ''`
    *   This defines an NPC event as a billing activity with description code 'C' and an empty description reason type.
*   **Order By:** `bil_account_id`, `bil_acy_dt desc`, `bil_acy_seq desc`.
*   **Purpose:** To create a dataset of all NPC events with their associated billing account and activity details.

## 9. `rnpc_count_prev_pre_2` Table: Counting NPC Events per Prior Year Window

This step counts the NPC events from `rnpc_all` that fall into the predefined prior year windows for each `cfxmlid`.

*   **Sources:**
    *   `init_inforce_to_cinbil_acct` (aliased `t1`, from step 7).
    *   `rnpc_all` (aliased `t2`, from step 8).
*   **Logic:** Left joins `t1` to `t2` on `t1.bil_account_id = t2.bil_account_id`.
*   **Counting NPC Events (`NonPayCancel_Count_prev_X`):**
    *   For each of the 5 prior year windows (e.g., `_prev_1`, `_prev_2`, etc.):
        *   `sum(t1.bil_prev_Xyr_start le t2.bil_acy_dt < t1.bil_prev_Xyr_end)`: This expression evaluates to 1 if an NPC event's date (`t2.bil_acy_dt`) falls within the specific prior year window (`bil_prev_Xyr_start` inclusive, `bil_prev_Xyr_end` exclusive), and 0 otherwise. The `sum()` aggregates these boolean outcomes.
        *   `* (case when t1.cinbill_acct_by_chain_exists_ind = 0 then . else 1 end)`: The sum is then multiplied by a factor. If `cinbill_acct_by_chain_exists_ind` is 0 (no billing account found for the chain), the count is multiplied by SAS missing value (`.`), effectively making the count missing. Otherwise, it's multiplied by 1, preserving the count.
*   **Group By:** `t1.cfxmlid`.
*   **Purpose:** To calculate the number of NPC events for each `cfxmlid` within each of the five defined prior year billing windows.

## 10. `rnpc_count_prev_pre_3` Table: Slimming Down NPC Counts

*   **Source:** `rnpc_count_prev_pre_2` (from step 9).
*   **Logic:** Selects `cfxmlid`, `policy_chain_id`, `cinbill_acct_by_chain_exists_ind`, `bil_eval_date`, and the five `NonPayCancel_Count_prev_X` columns.
*   **Purpose:** To create a more concise table with only the necessary identifiers and the calculated per-year NPC counts.

## 11. `rnpc_count_prev_2` Table: Calculating Cumulative NPC Counts

This step calculates cumulative NPC counts over the prior years.

*   **Source:** `rnpc_count_prev_pre_3` (from step 10).
*   **Logic:** Selects all columns from the source and adds new columns for cumulative counts:
    *   `NonPayCancel_Count_cprev_2 = NonPayCancel_Count_prev_1 + NonPayCancel_Count_prev_2`
    *   `NonPayCancel_Count_cprev_3 = NonPayCancel_Count_prev_1 + NonPayCancel_Count_prev_2 + NonPayCancel_Count_prev_3`
    *   And so on for `_cprev_4` and `_cprev_5`.
*   **Order By:** `cfxmlid`.
*   **Purpose:** To provide both individual prior year NPC counts and cumulative counts.

## 12. `BOP_cincibill` Table: Final Output

This is the final table produced by the script, combining policy information with the calculated NPC counts.

*   **Sources:**
    *   `cfxml_pols_chains_cutoffs` (aliased `t1`, from step 3).
    *   `rnpc_count_prev_2` (aliased `t2`, from step 11).
*   **Logic:** Left joins `t1` to `t2` on `t1.cfxmlid = t2.cfxmlid`.
*   **Selected Fields:**
    *   From `t1`: `cfxmlid`, `imageeffectivedate`, `imageexpirationdate`, `policy_chain_id`, `companycode`, `policysymbol`, `policynumber`, `statisticalpolicymodulenumber`, `policyeffectivedate`, `bil_eval_date`.
    *   From `t2`: Renamed NPC counts:
        *   `NonPayCancel_Count_prev_1` as `NPC_prev1`
        *   ...
        *   `NonPayCancel_Count_prev_5` as `NPC_prev5`
        *   `NonPayCancel_Count_cprev_2` as `NPC_cprev2`
        *   ...
        *   `NonPayCancel_Count_cprev_5` as `NPC_cprev5`
*   **Order By:** `t1.cfxmlid`.
*   **Purpose:** To produce the final output table containing policy identifiers and their associated NPC counts for 1 to 5 prior years (individual and cumulative), based on the specific date window logic defined in this script.

## 13. Final Cleanup of Work Tables

*   **Logic:** `proc datasets lib=work nolist; delete ...; run;`
*   **Purpose:** Deletes all remaining intermediate tables from the `work` library.
*   **Note:** This is a common practice in SAS to free up resources and keep the workspace tidy, but we do not need to replicate this in dbt as it handles intermediate tables differently.

This detailed breakdown should serve as a solid foundation for understanding and subsequently replicating the SAS script's logic in dbt.
