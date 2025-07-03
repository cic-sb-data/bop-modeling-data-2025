-- depends_on: {{ ref('lkp__bil_acct_key') }}

with 

raw as (
    select 
        bil_account_id as bil_acct_id,
        XCD_POLICY_ID as bil_policy_id,
        try_cast(MASTER_COMPANY_NBR as utinyint) as company_numb,
        BPT_ISU_CLT_ID as bil_policy_insured_client_id,
        try_cast(BPT_ISU_ADR_SEQ as uinteger) as bil_policy_insured_address_seq_numb,
        BPT_AGT_CLT_ID as bil_policy_agent_client_id,
        BPT_AGT_ADR_SEQ as bil_policy_agent_address_seq_numb,
        LOB_CD as lob_code,
        {{ recode__sas_date_format('POL_EFFECTIVE_DT') }} as policy_eff_date,
        {{ recode__sas_date_format('PLN_EXP_DT') }} as plan_exp_date,
        {{ recode__sas_date_format('BPT_STATUS_EFF_DT') }} as bil_policy_status_eff_date,
        {{ recode__sas_date_format('BPT_UW_STA_EFF_DT') }} as bil_policy_uw_status_eff_date,
        bil_state_pvn_cd as bil_state,
        bil_country_cd as bil_country,
        case when bpt_wro_prc_ind='Y' then 1 else 0 end as has_write_off_been_attempted,
        case when bpt_wro_prc_ind='N' then 1 else 0 end as is_write_off_not_allowed_by_plan,
        bil_sus_fu_rea_cd as bil_suspense_follow_up_reason_cd,
        case when bpt_agreement_ind='Y' then 1 else 0 end as is_term_associated_with_agreement,
        bil_to_fro_trf_nbr as bil_to_from_transfer_number,
        case when trim(bpt_audit_cd)='' then 0 else 1 end as is_policy_term_auditable,
        case when bpt_audit_cd='Y' then 1 else 0 end as has_potential_future_audit,
        case when bpt_term_split_ind='Y' then 1 else 0 end as has_gt1_bil_acct_for_policy,
        try_cast(bpt_below_min_cnt as integer) as bil_policy_count_of_no_invoice_bc_below_threshold,

        bpt_pol_uw_sta_cd as policy_uw_status_cd,
        case 
            when bpt_pol_uw_sta_cd='A' then 'Cancelled Subject to Audit'
            when bpt_pol_uw_sta_cd='C' then 'Pro-Rata Cancel'
            when bpt_pol_uw_sta_cd='D' then 'Cancelled Reissue'
            when bpt_pol_uw_sta_cd='F' then 'Flat Cancel'
            when bpt_pol_uw_sta_cd='G' then 'Flat Cancel for Reissue'
            when bpt_pol_uw_sta_cd='Q' then 'Quote'
            when bpt_pol_uw_sta_cd='R' then 'Cancelled'
            else 'Unknown billing policy status code: ' || bpt_pol_uw_sta_cd
        end as policy_uw_status,
        term_billing_plan as bil_plan_desc,
        case when bpt_act_col_cd='Y' then 1 else 0 end as acct_has_charges_in_collections,
        try_cast(bpt_pol_col_amt as double) as amt_sent_to_collections,
        bil_pol_status_cd as bil_policy_status_cd,
        * exclude(  
            bil_account_id_hash,
            xcd_policy_id,
            pol_effective_dt,
            MASTER_COMPANY_NBR,
            PLN_EXP_DT,
            BPT_ISU_CLT_ID,
            BPT_ISU_ADR_SEQ,
            BPT_AGT_CLT_ID,
            BPT_AGT_ADR_SEQ,
            bil_state_pvn_cd,
            bil_country_cd,
            bpt_wro_prc_ind,
            BPT_STATUS_EFF_DT,
            bpt_act_col_cd,
            bil_plan_cd,
            BPT_UW_STA_EFF_DT,
            bpt_agreement_ind,
            bil_to_fro_trf_nbr,
            bpt_audit_cd,
            lob_cd,
            bil_sus_fu_rea_cd,
            bpt_term_split_ind,
            bpt_below_min_cnt,
            bpt_pol_uw_sta_cd,
            bpt_pol_col_amt,
            bpt_issue_sys_id,
            bil_pol_status_cd,
            billing_policy_status,
            term_billing_plan,
            cfc_svc_cd

        ) 

    from {{ ref('raw__screngn__xcd_bil_policy_trm') }}
),


acct_id as (
    select
        bil_acct_id,
        bil_acct_key

    from {{ ref('lkp__bil_acct_key') }}
),

join_acct_key as (
    select
        acct_id.bil_acct_key,
        raw.* exclude (bil_acct_id, bil_account_id)

    from raw
    left join acct_id
        on raw.bil_acct_id = acct_id.bil_acct_id
),

pol_id as (
    select distinct
        associated_policy_key,
        sb_policy_key,
        bil_policy_trm_key,
        bil_policy_id,
        bil_policy_key,
        bil_acct_key,
        policy_eff_date

    from {{ ref('lkp__bil_policy') }}
),

join_policy_id as (
    select distinct
        pol_id.associated_policy_key,
        pol_id.sb_policy_key,
        pol_id.bil_policy_trm_key,
        pol_id.bil_policy_key,
        join_acct_key.* exclude (
            bil_policy_id,
            policy_eff_date,
            company_numb
        )

    from join_acct_key
    left join pol_id
        on join_acct_key.bil_acct_key = pol_id.bil_acct_key
        and join_acct_key.bil_policy_id = pol_id.bil_policy_id
        and join_acct_key.policy_eff_date = pol_id.policy_eff_date
)

select *
from join_policy_id
order by bil_policy_trm_key