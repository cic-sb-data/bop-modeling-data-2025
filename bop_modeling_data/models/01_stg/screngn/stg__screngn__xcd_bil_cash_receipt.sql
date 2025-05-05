with

raw as (
    select 
        bil_account_id,
        bil_account_id_hash,
        * exclude(
            bil_account_id,
            bil_account_id_hash
        ) replace(
            {{ recode__sas_date_format('BIL_DTB_DT') }} as BIL_DTB_DT,
            {{ recode__sas_date_format('BIL_DEPOSIT_DT') }} as BIL_DEPOSIT_DT,
            {{ recode__sas_date_format('BIL_RCT_RECEIVE_DT') }} as BIL_RCT_RECEIVE_DT
        ) 

    from {{ ref('raw__screngn__xcd_bil_cash_receipt') }}
)

select *
from raw