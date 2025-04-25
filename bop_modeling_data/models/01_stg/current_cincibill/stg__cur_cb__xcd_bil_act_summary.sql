

with

raw as (
    select 
        bil_account_id_hash as billing_acct_key,
        bil_account_id as billing_acct_id,
        
        bil_acy_dt as billing_activity_date,
        bil_acy_seq as billing_activity_sequence_numb,
        bil_acy_amt as billing_activity_amt,
        
        pol_symbol_cd as policy_sym,
        pol_nbr as policy_numb,
        bil_acy_des_cd as billing_activity_desc_cd,
        bil_des_rea_typ as billing_activity_desc_reason_type

    from {{ ref('raw__screngn__xcd_bil_act_summary') }}
    order by bil_account_id_hash 
)

select *
from raw

