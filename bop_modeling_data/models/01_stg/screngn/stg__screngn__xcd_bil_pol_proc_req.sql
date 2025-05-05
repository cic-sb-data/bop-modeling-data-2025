with

raw as (
    select
        bil_account_id,
        bil_account_id_hash,
        * exclude(
            bil_account_id,
            bil_account_id_hash
        ) replace (
            {{ recode__sas_date_format('POL_EFFECTIVE_DT') }} as POL_EFFECTIVE_DT,
            {{ recode__sas_date_format('BIL_ACT_DT') }} as BIL_ACT_DT
        ) 

    from {{ ref('raw__screngn__xcd_bil_pol_proc_req') }}
)

select *
from raw