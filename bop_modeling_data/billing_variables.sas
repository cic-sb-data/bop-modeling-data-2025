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

