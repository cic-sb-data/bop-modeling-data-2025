-- depends_on: {{ ref('xcd_bil_acct_key') }}

with 

raw as (
    select 
        bil_account_id,
        * exclude(
            bil_account_id,
            bil_account_id_hash
        ) replace(
            {{ recode__sas_date_format('POL_EFFECTIVE_DT') }} as POL_EFFECTIVE_DT,
            {{ recode__sas_date_format('PLN_EXP_DT') }} as PLN_EXP_DT,
            {{ recode__sas_date_format('BPT_STATUS_EFF_DT') }} as BPT_STATUS_EFF_DT,
            {{ recode__sas_date_format('BPT_UW_STA_EFF_DT') }} as BPT_UW_STA_EFF_DT
        ) 

    from {{ ref('raw__screngn__xcd_bil_policy_trm') }}
),

add_acct_key as ({{ add_bil_acct_key('raw') }}),

add_id as (select row_number() over (order by bil_account_id, pol_nbr) as bil_policy_key, * from add_acct_key)

select *
from add_id