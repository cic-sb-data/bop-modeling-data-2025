with

raw_billing_pols as (
    select distinct
        bil_account_id_hash as billing_acct_key,
        md5_number(XCD_POLICY_ID) as billing_policy_key,
        XCD_POLICY_ID as billing_policy_id,
        BIL_ACCOUNT_ID as billing_acct_id,
        POL_SYMBOL_CD as policy_sym,
        try_cast(POL_NBR as uint32) as policy_numb,
        POL_EFFECTIVE_DT as policy_eff_date

    from {{ ref('raw__screngn__xcd_bil_cash_dsp') }}
    order by
        billing_acct_key,
        billing_policy_key,
        policy_eff_date
),

associated_policies as (
    select 
        associated_policy_key,
        associated_sb_policy_key,
        policy_chain_id,
        {{ five_key() }}

    from {{ ref('lkp__associated_policies') }}
),

filter_raw_billing_policies as (
    select 
        associated_policies.associated_policy_key,
        associated_policies.associated_sb_policy_key,
        raw_billing_pols.* 

    from raw_billing_pols
    left join associated_policies
        on raw_billing_pols.policy_sym = associated_policies.policy_sym
        and raw_billing_pols.policy_numb = associated_policies.policy_numb
        and raw_billing_pols.policy_eff_date = associated_policies.policy_eff_date

    where associated_policies.associated_policy_key is not null

    order by 
        associated_policies.associated_policy_key,
        associated_policies.associated_sb_policy_key,
        raw_billing_pols.billing_acct_key,
        raw_billing_pols.billing_policy_key,
        raw_billing_pols.policy_eff_date
)


select *
from filter_raw_billing_policies