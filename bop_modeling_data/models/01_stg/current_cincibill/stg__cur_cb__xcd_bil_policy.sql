with

raw as (
    select 
        bil_account_id_hash as billing_acct_key,
        bil_account_id as billing_acct_id,
        bil_account_nbr as billing_acct_numb,
        
        pol_symbol_cd as policy_sym,
        pol_nbr as policy_numb

    from {{ ref('raw__screngn__xcd_bil_policy') }}
    order by 
        policy_sym,
        policy_numb
)

select *
from raw

