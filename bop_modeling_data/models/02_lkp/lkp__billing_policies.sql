with

raw as (
    select distinct
        bil_account_id_hash as billing_acct_key,
        md5_number(XCD_POLICY_ID) as billing_policy_key,
        XCD_POLICY_ID as billing_policy_id,
        BIL_ACCOUNT_ID as billing_acct_id,
        POL_SYMBOL_CD as policy_sym,
        POL_NBR as policy_numb,
        POL_EFFECTIVE_DT as policy_eff_date

    from {{ ref('raw__screngn__xcd_bil_cash_dsp') }}
    order by
        billing_acct_key,
        billing_policy_key,
        policy_eff_date
)


select *
from raw