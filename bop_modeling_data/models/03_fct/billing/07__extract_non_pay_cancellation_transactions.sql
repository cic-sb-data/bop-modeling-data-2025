-- Extract non-pay cancel transactions from billing activity summary, matching SAS rnpc_all logic.

with

act_summary as (
    select *
    from {{ ref('stg__screngn__xcd_bil_act_summary') }}
),

filtered as (
    select
        bil_account_id,
        bil_acy_dt,
        bil_acy_seq,
        bil_acy_amt,
        left(trim(policy_sym), 2) as pol_symbol_2,
        left(trim(policy_numb), 7) as pol_nbr
    from act_summary
    where bil_acy_des_cd = 'C'
      and (bil_des_rea_typ is null or bil_des_rea_typ = '')
)

select *
from filtered
