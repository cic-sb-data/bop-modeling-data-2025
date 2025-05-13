with

raw as (
    select 
        bil_account_id as billing_acct_id,
        XCD_POLICY_ID as billing_policy_id,
        bil_account_id_hash,
        * exclude(
            bil_account_id,
            bil_account_id_hash
        ) replace (
            try_cast(bil_dtb_dt as date) as BIL_DTB_DT,
            try_cast(POL_NBR as ubigint) as POL_NBR,
            {{ recode__sas_date_format('POL_EFFECTIVE_DT') }} as POL_EFFECTIVE_DT,
            {{ recode__sas_date_format('BIL_ADJ_DUE_DT') }} as BIL_ADJ_DUE_DT,
            {{ recode__sas_date_format('BIL_INV_DT') }} as BIL_INV_DT,
            {{ recode__sas_date_format('BIL_DSP_DT') }} as BIL_DSP_DT
        )

    from {{ ref('raw__screngn__xcd_bil_cash_dsp') }}
),

add_acct_key as ({{ add_account_key('raw') }}),
add_policy_key as ({{ add_policy_key('raw') }})

select *
from add_policy_key