# dm__npc_counts Model Documentation and Implementation Plan

## 1. Objective

The `dm__npc_counts` model calculates Non-Payment Cancellation (NPC) counts for insurance policies. The logic implemented is based on the analysis of the `current_npc_logic.sas` script, which has specific definitions for prior year windows and NPC event identification.

**Key Distinction:** The NPC calculation logic, particularly the definition of prior year windows, in `current_npc_logic.sas` (and therefore in this plan) differs from the general-purpose `%make_prior_year_cols` SAS macro discussed in other documentation (e.g., `dm__npc_counts__roadmap.md`). This model specifically adheres to `current_npc_logic.sas`.

## 2. Output Grain

The final output of `dm__npc_counts` will be at the policy level, identified by:
*   `sb_policy_key` (equivalent to `cfxmlid` in the SAS script)
*   `policyeffectivedate`

## 3. Core Logic from `current_npc_logic.sas`

The following key logic points from `current_npc_logic.sas` are implemented:

*   **Target Policy Identification:** Starts with a set of policies identified by `sb_policy_key`.
*   **Date Cutoff Definitions:**
    *   `bil_eval_date`: Calculated as 4 months prior to the `policyeffectivedate`.
    *   `NonPayCancel_Count_prev_1` Window (1st Prior Year): An 8-month period from `policyeffectivedate - 1 year` up to (but not including) `policyeffectivedate - 4 months`.
    *   `NonPayCancel_Count_prev_2` through `_prev_5` Windows (Subsequent Prior Years): These are 12-month periods. For example, the 2nd prior year window is `[policyeffectivedate - 2 years, policyeffectivedate - 1 year)`.
    *   There is **no** `nth_prior_year = 0` concept as found in the `%make_prior_year_cols` macro.
*   **NPC Event Definition:** An NPC event is identified where `bil_acy_des_cd = 'C'` AND `bil_des_rea_typ = ''` in the billing activity data.
*   **Linkage to Billing Data:** Policies are linked to billing accounts (`bil_account_id`) via their `policy_chain_id`.
*   **Handling Missing Billing Accounts:** If a policy's chain does not link to any `bil_account_id`, its NPC counts for all periods will be `NULL`.

## 4. Data Lineage and Input Models

The `dm__npc_counts` model will primarily rely on the following dbt models:

*   **`lkp__associated_policies` (or `lkp__sb_policy_key`)**:
    *   **Purpose:** Provides the initial set of target policies.
    *   **Key Fields Used:** `associated_sb_policy_key` (as `sb_policy_key`), `policy_eff_date` (as `policyeffectivedate`), `policy_chain_id`, and other policy-identifying components (`companycode`, `policysymbol`, `policynumber`, `statisticalpolicymodulenumber`, `imageexpirationdate`).
*   **`stg__modcom__policy_chain_v3`**:
    *   **Purpose:** Staged version of the `ACTCOLIB.POLICY_CHAIN_V3` table. Used to link billing records (via their full policy keys) to `policy_chain_id`.
    *   **Key Fields Used:** `policy_chain_id` and policy component fields for joining (`COMPANY_NUMB`, `POLICY_SYM`, `POLICY_NUMB`, `POLICY_MODULE`, `POLICY_EFF_DATE`).
*   **`stg__screngn__xcd_bil_policy`**:
    *   **Purpose:** Staged billing policy data. Source of `bil_account_id` and the policy keys associated with billing records.
    *   **Key Fields Used:** `bil_account_id`, and policy component fields (company, symbol, number, module, effective date of the term).
*   **`stg__screngn__xcd_bil_act_summary`**:
    *   **Purpose:** Staged billing activity summary. Source of NPC events.
    *   **Key Fields Used:** `bil_account_id`, `bil_acy_dt` (activity date), `bil_acy_des_cd`, `bil_des_rea_typ`.

## 5. dbt Modeling Approach (CTEs within `dm__npc_counts.sql`)

The following CTEs will be used to construct the `dm__npc_counts` model:

### CTE 1: `target_policies_with_cutoffs`
*   **Source:** `lkp__associated_policies` (aliased `ap`) or `lkp__sb_policy_key`.
*   **Logic:**
    1.  Select distinct `ap.associated_sb_policy_key` as `sb_policy_key`, `ap.policy_eff_date` as `policyeffectivedate`, `ap.policy_chain_id`, and other required policy attributes (`companycode`, `policysymbol`, `policynumber`, `statisticalpolicymodulenumber`, `imageexpirationdate`).
    2.  Calculate date cutoffs based on `policyeffectivedate` as per `current_npc_logic.sas`:
        *   `bil_eval_date = DATEADD('month', -4, policyeffectivedate)`
        *   `bil_prev_1yr_start = DATEADD('year', -1, policyeffectivedate)`
        *   `bil_prev_1yr_end = bil_eval_date`
        *   `bil_prev_2yr_start = DATEADD('year', -2, policyeffectivedate)`
        *   `bil_prev_2yr_end = bil_prev_1yr_start`
        *   `bil_prev_3yr_start = DATEADD('year', -3, policyeffectivedate)`
        *   `bil_prev_3yr_end = bil_prev_2yr_start`
        *   `bil_prev_4yr_start = DATEADD('year', -4, policyeffectivedate)`
        *   `bil_prev_4yr_end = bil_prev_3yr_start`
        *   `bil_prev_5yr_start = DATEADD('year', -5, policyeffectivedate)`
        *   `bil_prev_5yr_end = bil_prev_4yr_start`
*   **Output:** `sb_policy_key`, `policyeffectivedate`, `policy_chain_id`, other policy attributes, and all calculated date cutoffs.

### CTE 2: `billing_accounts_to_chains`
*   **Source:** `stg__screngn__xcd_bil_policy` (aliased `bp`), `stg__modcom__policy_chain_v3` (aliased `pc3`).
*   **Logic:**
    1.  From `bp`, select `bil_account_id` and the necessary policy key components (e.g., `company_code`, `policy_symbol`, `policy_number`, `policy_module`, `term_effective_date_from_billing_record`). Ensure these components match the definitions in `pc3`. Apply transformations if needed (e.g., company code mapping from SAS).
    2.  Join with `pc3` on these full policy key components to retrieve `pc3.policy_chain_id`.
*   **Output:** Distinct `bil_account_id`, `policy_chain_id`.

### CTE 3: `policies_linked_to_billing_accounts`
*   **Source:** `target_policies_with_cutoffs` (aliased `tpc`), `billing_accounts_to_chains` (aliased `bac`).
*   **Logic:**
    1.  Left join `tpc` to `bac` on `tpc.policy_chain_id = bac.policy_chain_id`.
    2.  Create `cinbill_acct_by_chain_exists_ind = CASE WHEN bac.bil_account_id IS NOT NULL THEN 1 ELSE 0 END`.
*   **Output:** All columns from `tpc`, `bac.bil_account_id`, `cinbill_acct_by_chain_exists_ind`.
    *   *Note: A single `sb_policy_key` might be fanned out if its `policy_chain_id` links to multiple `bil_account_id`s. This is handled by the aggregation in the next steps.*

### CTE 4: `npc_events_raw`
*   **Source:** `stg__screngn__xcd_bil_act_summary` (aliased `bas`).
*   **Logic:**
    1.  Filter for NPC events: `WHERE bas.bil_acy_des_cd = 'C' AND bas.bil_des_rea_typ = ''`.
    2.  Select `bas.bil_account_id`, `bas.bil_acy_dt` (activity date).
*   **Output:** `bil_account_id`, `bil_acy_dt` for each raw NPC event.

### CTE 5: `policy_npc_event_counts`
*   **Source:** `policies_linked_to_billing_accounts` (aliased `plb`), `npc_events_raw` (aliased `npc`).
*   **Logic:**
    1.  Join `plb` with `npc` on `plb.bil_account_id = npc.bil_account_id`.
    2.  Filter for relevant events: `WHERE npc.bil_acy_dt < plb.policyeffectivedate`.
    3.  Group by all columns from `plb` (i.e., `sb_policy_key`, `policyeffectivedate`, `policy_chain_id`, other policy attributes, all date cutoffs, `cinbill_acct_by_chain_exists_ind`, and `plb.bil_account_id` if distinct counts per account are needed before final aggregation, though SAS logic implies aggregation across all accounts in the chain). For simplicity, the SAS script effectively groups by `cfxmlid` (our `sb_policy_key`) at the end. We will group by all `plb` columns that define the unique policy and its attributes.
    4.  Calculate counts for each period:
        *   `NonPayCancel_Count_prev_1 = SUM(CASE WHEN npc.bil_acy_dt >= plb.bil_prev_1yr_start AND npc.bil_acy_dt < plb.bil_prev_1yr_end THEN 1 ELSE 0 END)`
        *   `NonPayCancel_Count_prev_2 = SUM(CASE WHEN npc.bil_acy_dt >= plb.bil_prev_2yr_start AND npc.bil_acy_dt < plb.bil_prev_2yr_end THEN 1 ELSE 0 END)`
        *   ... and so on for `_prev_3`, `_prev_4`, `_prev_5`.
*   **Output:** `sb_policy_key`, `policyeffectivedate`, other identifying policy attributes, `cinbill_acct_by_chain_exists_ind`, and the five `NonPayCancel_Count_prev_X` columns.

### CTE 6: `final_npc_counts`
*   **Source:** `policy_npc_event_counts` (aliased `pnec`).
*   **Logic:**
    1.  This CTE aggregates the counts per `sb_policy_key` if the previous step fanned out due to multiple billing accounts. If `policy_npc_event_counts` is already at the `sb_policy_key` grain, this CTE focuses on null handling and cumulative counts. Assuming `policy_npc_event_counts` might have multiple rows per `sb_policy_key` if a chain has multiple accounts, we first aggregate to the `sb_policy_key` grain.
        *   Group by `sb_policy_key`, `policyeffectivedate`, other identifying policy attributes from `pnec` (like `companycode`, etc.), `bil_eval_date`, `cinbill_acct_by_chain_exists_ind`.
        *   `NPC_prev1 = SUM(pnec.NonPayCancel_Count_prev_1)`
        *   ... and so on for `NPC_prev2` to `NPC_prev5`.
    2.  Apply `NULL` logic based on `cinbill_acct_by_chain_exists_ind`:
        *   `NPC_prev1 = CASE WHEN pnec.cinbill_acct_by_chain_exists_ind = 0 THEN NULL ELSE NPC_prev1 END`
        *   ... and so on for `NPC_prev2` to `NPC_prev5`.
    3.  Calculate cumulative counts (these also become `NULL` if `cinbill_acct_by_chain_exists_ind = 0`):
        *   `NPC_cprev2 = CASE WHEN pnec.cinbill_acct_by_chain_exists_ind = 0 THEN NULL ELSE COALESCE(NPC_prev1, 0) + COALESCE(NPC_prev2, 0) END`
        *   `NPC_cprev3 = CASE WHEN pnec.cinbill_acct_by_chain_exists_ind = 0 THEN NULL ELSE COALESCE(NPC_prev1, 0) + COALESCE(NPC_prev2, 0) + COALESCE(NPC_prev3, 0) END`
        *   ... and so on for `NPC_cprev4`, `NPC_cprev5`.
*   **Output:** `sb_policy_key`, `policyeffectivedate`, `imageexpirationdate`, `policy_chain_id`, `companycode`, `policysymbol`, `policynumber`, `statisticalpolicymodulenumber`, `bil_eval_date`, `NPC_prev1`...`NPC_prev5`, `NPC_cprev2`...`NPC_cprev5`.

## 6. Final Model Selection

The final `SELECT` statement will pull all required columns from the `final_npc_counts` CTE, ensuring the output matches the structure of the SAS `BOP_cincibill` table as closely as possible.

```sql
SELECT
    sb_policy_key,
    policyeffectivedate,
    imageexpirationdate, -- Sourced from target_policies_with_cutoffs
    policy_chain_id,     -- Sourced from target_policies_with_cutoffs
    companycode,         -- Sourced from target_policies_with_cutoffs
    policysymbol,        -- Sourced from target_policies_with_cutoffs
    policynumber,        -- Sourced from target_policies_with_cutoffs
    statisticalpolicymodulenumber, -- Sourced from target_policies_with_cutoffs
    bil_eval_date,       -- Sourced from target_policies_with_cutoffs
    NPC_prev1,
    NPC_prev2,
    NPC_prev3,
    NPC_prev4,
    NPC_prev5,
    NPC_cprev2,
    NPC_cprev3,
    NPC_cprev4,
    NPC_cprev5
FROM final_npc_counts
ORDER BY sb_policy_key;
```

## Appendix: Original SAS Logic

```sas
proc sql;
create table Prop_Cfxs as 
		select distinct cfxmlid
from Exps_Raw.&prop_rerated_raw.
; quit;

proc sql;
create table GL_Cfxs as 
		select distinct cfxmlid
from Exps_Raw.&gl_rerated_raw.
; quit;


/* Construct distinct list of policy images found in the modeling data for PROP and/or GL */
proc sql;
create table work.prop_cfxml_pol_keys as select distinct
	a.cfxmlid
	,b.companycode
	,b.policysymbol
	,b.policynumber
	,b.policyeffectivedate format=yymmddd10.
	,b.statisticalpolicymodulenumber
	,b.imageeffectivedate format=yymmddd10.
	,b.imageexpirationdate format=yymmddd10.

from Prop_Cfxs as a
	Left join smbizhal.&prop_ev. as b
	  On (a.cfxmlid=b.cfxmlid)
; quit;

proc sql;
create table work.gl_cfxml_pol_keys as select distinct
	a.cfxmlid
	,b.companycode
	,b.policysymbol
	,b.policynumber
	,b.policyeffectivedate format=yymmddd10.
	,b.statisticalpolicymodulenumber
	,b.imageeffectivedate format=yymmddd10.
	,b.imageexpirationdate format=yymmddd10.

from GL_Cfxs as a
	Left join smbizhal.&gl_ev. as b
	  On (a.cfxmlid=b.cfxmlid)
; quit;

data work.cfxml_pol_keys;
set work.prop_cfxml_pol_keys work.gl_cfxml_pol_keys;
run;

proc sort data=work.cfxml_pol_keys out=cfxml_pol_keys nodupkey;
by cfxmlid;
run;


proc sql;
create table cfxml_pols_chains_cutoffs as select
	t1.*
	,t2.policy_chain_id

	/* Prior claims evaluation date and cutoffs */
	,intnx('month', t1.imageeffectivedate, -4, 's') format=yymmddd10. as clm_eval_date

    ,intnx('month', calculated clm_eval_date, -8,  's') format=yymmddd10. as clm_prev_1yr_start
    ,intnx('month', calculated clm_eval_date, -20, 's') format=yymmddd10. as clm_prev_2yr_start 
    ,intnx('month', calculated clm_eval_date, -32, 's') format=yymmddd10. as clm_prev_3yr_start 
    ,intnx('month', calculated clm_eval_date, -44, 's') format=yymmddd10. as clm_prev_4yr_start 
    ,intnx('month', calculated clm_eval_date, -56, 's') format=yymmddd10. as clm_prev_5yr_start 

    ,calculated clm_eval_date       format=yymmddd10. as clm_prev_1yr_end 
    ,calculated clm_prev_1yr_start  format=yymmddd10. as clm_prev_2yr_end 
    ,calculated clm_prev_2yr_start  format=yymmddd10. as clm_prev_3yr_end 
    ,calculated clm_prev_3yr_start  format=yymmddd10. as clm_prev_4yr_end 
    ,calculated clm_prev_4yr_start  format=yymmddd10. as clm_prev_5yr_end 

	/* Billing evaluation date and cutoffs */
	,intnx('month', t1.imageeffectivedate, -4, 's') format=yymmddd10. as bil_eval_date

	,intnx("year", t1.imageeffectivedate, -1, 's') format=yymmddd10. as bil_prev_1yr_start
	,intnx("year", t1.imageeffectivedate, -2, 's') format=yymmddd10. as bil_prev_2yr_start
	,intnx("year", t1.imageeffectivedate, -3, 's') format=yymmddd10. as bil_prev_3yr_start
	,intnx("year", t1.imageeffectivedate, -4, 's') format=yymmddd10. as bil_prev_4yr_start
	,intnx("year", t1.imageeffectivedate, -5, 's') format=yymmddd10. as bil_prev_5yr_start

	,calculated bil_eval_date		format=yymmddd10. as bil_prev_1yr_end
	,calculated bil_prev_1yr_start 	format=yymmddd10. as bil_prev_2yr_end
	,calculated bil_prev_2yr_start 	format=yymmddd10. as bil_prev_3yr_end
	,calculated bil_prev_3yr_start 	format=yymmddd10. as bil_prev_4yr_end
	,calculated bil_prev_4yr_start 	format=yymmddd10. as bil_prev_5yr_end

from cfxml_pol_keys as t1
left join ACTCOLIB.POLICY_CHAIN_V3 as t2
      ON (case	when t1.companycode = 'CID' then 3
				when t1.companycode = 'CIC' then 5
				when t1.companycode = 'CCC' then 7 end 	= t2.COMPANY_NUMB)
     AND (t1.policysymbol      							= t2.POLICY_SYM) 
     AND (input(t1.policynumber,9.)  					= t2.POLICY_NUMB) 
     AND (t1.policyeffectivedate 						= t2.POLICY_EFF_DATE) 
     AND (input(t1.statisticalpolicymodulenumber,3.)	= t2.POLICY_MODULE)

order by input(scan(t1.cfxmlid,2,'.'),9.), input(scan(t1.cfxmlid,3,'.'),4.)
; quit;

proc datasets lib=work nolist;
delete prop_cfxml_pol_keys;
delete gl_cfxml_pol_keys;
delete cfxml_pol_keys;
quit;



/*==========================================*/
/*  Grab information from CinciBill tables  */
/*==========================================*/

proc sql;
create table pol_s2n_acct as
select distinct	
	bil_account_id
	,bil_account_nbr
	,substr(pol_symbol_cd,1,2) as pol_symbol_2
	,input(pol_nbr,best12.) as pol_nbr_numb
	,pol_nbr
from screngn.xcd_bil_policy
order by
	pol_symbol_2
	,pol_nbr
; quit;

* First, add the chain id to pol_s2n_acct by simple lookup;
proc sql;
create table s2n_acct_to_chn_closure_step1 as
select distinct
	t1.pol_symbol_2
	,t1.pol_nbr
	,t1.pol_nbr_numb
	,t1.bil_account_id
	,t1.bil_account_nbr
	,t2.policy_chain_id
from pol_s2n_acct as t1
left join common.lkup_policy_chain_by_s2n as t2
	 on t1.pol_symbol_2 = t2.policy_sym_2
	and t1.pol_nbr_numb = t2.policy_numb
order by
	t2.policy_chain_id
; quit;

* next, close up the relationship by getting all of the other <Policy_Symbol_2, Policy_Number> in the policy chain, since all of these have to be related to account;
proc sql;
create table all_bil_acct_for_s2n as
select distinct
	t2.policy_sym_2
	,t2.policy_numb
	,t1.bil_account_id
	,t1.bil_account_nbr
	,t1.policy_chain_id
from s2n_acct_to_chn_closure_step1 as t1
left join common.lkup_policy_chain_by_s2n as t2
	 on t1.policy_chain_id = t2.policy_chain_id
; quit;


/*	Construct the ADD_DATE_CUTOFFS table for use later in Bob's code  */
/*proc sql;*/
/*create table ADD_DATE_CUTOFFS_2 as*/
/*select distinct*/
/*	t1.policysymbol as policy_sym*/
/*	,t1.policynumber as policy_numb*/
/*	,t1.policyeffectivedate as policy_eff_date*/
/*	,t1.imageeffectivedate*/
/*	,t2.policy_chain_id*/
/*	,intnx('month',t1.imageeffectivedate,-4,'s') format=yymmddd10. as eval_date2*/
/*	,intnx('year',t1.imageeffectivedate,-1,'s') format=yymmddd10. as prev_1yr_start2*/
/*	,intnx('year',t1.imageeffectivedate,-2,'s') format=yymmddd10. as prev_2yr_start2*/
/*	,intnx('year',t1.imageeffectivedate,-3,'s') format=yymmddd10. as prev_3yr_start2*/
/*	,intnx('year',t1.imageeffectivedate,-4,'s') format=yymmddd10. as prev_4yr_start2*/
/*	,intnx('year',t1.imageeffectivedate,-5,'s') format=yymmddd10. as prev_5yr_start2*/
/*	,intnx('month',t1.imageeffectivedate,-4,'s') format=yymmddd10. as prev_1yr_end2*/
/*	,intnx('year',t1.imageeffectivedate,-1,'s') format=yymmddd10. as prev_2yr_end2*/
/*	,intnx('year',t1.imageeffectivedate,-2,'s') format=yymmddd10. as prev_3yr_end2*/
/*	,intnx('year',t1.imageeffectivedate,-3,'s') format=yymmddd10. as prev_4yr_end2*/
/*	,intnx('year',t1.imageeffectivedate,-4,'s') format=yymmddd10. as prev_5yr_end2*/
/*from _g1 as t1*/
/*left join common.lkup_policy_chain_by_s2n as t2*/
/*	 on substr(t1.policysymbol,1,2) = t2.policy_sym_2*/
/*	and t1.policynumber = t2.policy_numb*/
/*; quit;*/



proc sql;
create table init_inforce_to_cinbil_acct as
select distinct
	t1.cfxmlid
	,t1.companycode
	,t1.policysymbol
	,t1.policynumber
	,t1.statisticalpolicymodulenumber
	,t1.policyeffectivedate
	,t1.imageeffectivedate
	,t1.bil_eval_date
	,t1.bil_prev_1yr_start
	,t1.bil_prev_2yr_start
	,t1.bil_prev_3yr_start
	,t1.bil_prev_4yr_start
	,t1.bil_prev_5yr_start
	,t1.bil_prev_1yr_end
	,t1.bil_prev_2yr_end
	,t1.bil_prev_3yr_end
	,t1.bil_prev_4yr_end
	,t1.bil_prev_5yr_end
	,t1.policy_chain_id
	,t2.bil_account_id
	,t2.bil_account_nbr
	,max(not missing(t2.bil_account_id)) as cinbill_acct_by_chain_exists_ind
/*from ADD_DATE_CUTOFFS_2 as t1															*/
from cfxml_pols_chains_cutoffs as t1
left join all_bil_acct_for_s2n as t2
	 on t1.policy_chain_id = t2.policy_chain_id
group by 
	t1.cfxmlid
order by t2.bil_account_id
; quit;


/*	RNPC Count - uses the shortcut table RNPC_ALL  */
proc sql;
create table rnpc_all as
select
	bil_account_id
	,bil_acy_dt
	,bil_acy_seq
	,bil_acy_amt
	,substr(strip(pol_symbol_cd),1,2) length=2 as pol_symbol_2
	,substr(strip(pol_nbr),1,7) length=7 as pol_nbr
from screngn.xcd_bil_act_summary
where bil_acy_des_cd = 'C' and bil_des_rea_typ = ''
order by
	bil_account_id
	,bil_acy_dt desc
	,bil_acy_seq desc
; quit;



proc sql;
create table rnpc_count_prev_pre_2 as
select distinct
	t1.cfxmlid
	,t1.companycode
	,t1.policysymbol
	,t1.policynumber
	,t1.statisticalpolicymodulenumber
	,t1.policyeffectivedate
	,t1.imageeffectivedate
	,t1.bil_eval_date
	,t1.bil_prev_1yr_start
	,t1.bil_prev_2yr_start
	,t1.bil_prev_3yr_start
	,t1.bil_prev_4yr_start
	,t1.bil_prev_5yr_start
	,t1.bil_prev_1yr_end
	,t1.bil_prev_2yr_end
	,t1.bil_prev_3yr_end
	,t1.bil_prev_4yr_end
	,t1.bil_prev_5yr_end
	,t1.policy_chain_id
	,t1.cinbill_acct_by_chain_exists_ind

	/* NonPayCancel_Count_prev variables*/
	,(sum(t1.bil_prev_1yr_start le t2.bil_acy_dt < t1.bil_prev_1yr_end)
		* (case when t1.cinbill_acct_by_chain_exists_ind = 0 then . else 1 end)) as NonPayCancel_Count_prev_1

	,(sum(t1.bil_prev_2yr_start le t2.bil_acy_dt < t1.bil_prev_2yr_end)
		* (case when t1.cinbill_acct_by_chain_exists_ind = 0 then . else 1 end)) as NonPayCancel_Count_prev_2

	,(sum(t1.bil_prev_3yr_start le t2.bil_acy_dt < t1.bil_prev_3yr_end)
		* (case when t1.cinbill_acct_by_chain_exists_ind = 0 then . else 1 end)) as NonPayCancel_Count_prev_3

	,(sum(t1.bil_prev_4yr_start le t2.bil_acy_dt < t1.bil_prev_4yr_end)
		* (case when t1.cinbill_acct_by_chain_exists_ind = 0 then . else 1 end)) as NonPayCancel_Count_prev_4

	,(sum(t1.bil_prev_5yr_start le t2.bil_acy_dt < t1.bil_prev_5yr_end)
		* (case when t1.cinbill_acct_by_chain_exists_ind = 0 then . else 1 end)) as NonPayCancel_Count_prev_5

from init_inforce_to_cinbil_acct as t1
left join rnpc_all as t2
	 on t1.bil_account_id = t2.bil_account_id
group by 
	t1.cfxmlid
; quit;

proc sql;
create table rnpc_count_prev_pre_3 as
select
	cfxmlid
	,policy_chain_id
	,cinbill_acct_by_chain_exists_ind
	,bil_eval_date
	,NonPayCancel_Count_prev_1
	,NonPayCancel_Count_prev_2
	,NonPayCancel_Count_prev_3
	,NonPayCancel_Count_prev_4
	,NonPayCancel_Count_prev_5
from rnpc_count_prev_pre_2
; quit;

proc sql;
create table rnpc_count_prev_2 as
select
	*
	,NonPayCancel_Count_prev_1 + NonPayCancel_Count_prev_2 as NonPayCancel_Count_cprev_2
	,NonPayCancel_Count_prev_1 + NonPayCancel_Count_prev_2 + NonPayCancel_Count_prev_3 as NonPayCancel_Count_cprev_3
	,NonPayCancel_Count_prev_1 + NonPayCancel_Count_prev_2 + NonPayCancel_Count_prev_3 + NonPayCancel_Count_prev_4 as NonPayCancel_Count_cprev_4
	,NonPayCancel_Count_prev_1 + NonPayCancel_Count_prev_2 + NonPayCancel_Count_prev_3 + NonPayCancel_Count_prev_4 + NonPayCancel_Count_prev_5 as NonPayCancel_Count_cprev_5
from rnpc_count_prev_pre_3
order by cfxmlid
; quit;


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
/*	,t2.cinbill_acct_by_chain_exists_ind*/
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

proc datasets lib=work nolist;
delete 
	rnpc_count_prev_pre_3
	rnpc_count_prev_pre_2
	rnpc_all
	init_inforce_to_cinbill_acct
	s2n_acct_to_chn_closure_step1
	all_bil_acct_for_s2n
	pol_s2n_acct

	CFXML_POL_KEYS
	INIT_INFORCE_TO_CINBIL_ACCT
	RNPC_COUNT_PREV_2
; run;
```