with

dates as (select * from {{ ref('lkp__dates') }}),

billing_policies as (   
    select distinct 
        billing_sb_policy_key,
        associated_policy_key,
        associated_sb_policy_key,
        billing_acct_key,
        billing_policy_key

    from {{ ref('lkp__billing_policies') }}
    order by billing_sb_policy_key
),

act_summary as (
    select
        billing_acct_key,
        billing_activity_date,
        billing_activity_sequence_numb,
        billing_activity_amt
    
    from {{ ref('stg__cur_cb__xcd_bil_act_summary') }}
    where
        billing_activity_desc_cd='C' 
        and billing_activity_desc_reason_type is null
    order by 
        billing_acct_key, 
        billing_activity_date
),

join_policies_to_acct_summary as (
    select 
        act.*,
        pol.* exclude (billing_acct_key)

    from act_summary as act 
    inner join billing_policies as pol 
        on act.billing_acct_key = pol.billing_acct_key

    where associated_sb_policy_key is not null
)

select *
from join_policies_to_acct_summary