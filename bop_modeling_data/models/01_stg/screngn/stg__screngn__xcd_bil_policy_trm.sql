-- depends_on: {{ ref('xcd_bil_acct_key') }}

with 

raw as (
    select 
        bil_account_id as bil_acct_id,
        XCD_POLICY_ID as bil_policy_id,
        {{ recode__sas_date_format('POL_EFFECTIVE_DT') }} as policy_eff_date,
        {{ recode__sas_date_format('PLN_EXP_DT') }} as plan_exp_date,
        {{ recode__sas_date_format('BPT_STATUS_EFF_DT') }} as bpt_status_eff_date,
        {{ recode__sas_date_format('BPT_UW_STA_EFF_DT') }} as bpt_uw_status_eff_date,
        * exclude(bil_account_id_hash) 

    from {{ ref('raw__screngn__xcd_bil_policy_trm') }}
),

policy as (
    select distinct
        bil_acct_id,
        bil_policy_id,
        policy_sym,
        policy_numb

    from {{ ref('stg__screngn__xcd_bil_policy') }}
    where bil_policy_id is not null
),

join_policy_id as (
    select
        raw.*,
        policy.policy_sym,
        policy.policy_numb

    from raw
    left join policy
        on raw.bil_policy_id = policy.bil_policy_id
        and raw.bil_acct_id = policy.bil_acct_id

),

add_acct_key as ({{ add_bil_acct_key('join_policy_id') }}),


add_id as (
    select 
        row_number() over (
            order by 
                bil_acct_key, 
                bil_policy_id, 
                policy_sym, 
                policy_numb
        ) as bil_policy_key, 
        * 

    from add_acct_key
)


select *
from add_id
order by bil_policy_key