-- Extract non-pay cancel transactions from billing activity summary, matching SAS rnpc_all logic.

with

act_summary as (
    select *
    from {{ ref('stg__screngn__xcd_bil_act_summary') }}
),

filtered as (
    select
        bil_act_summary_key,
        bil_acct_key,
        bil_act_amt

    from act_summary
    where bil_act_desc_code = 'C'
    and (
        bil_act_reason_type_code is null 
        or bil_act_reason_type_code = ''
    )
)

select *
from filtered
