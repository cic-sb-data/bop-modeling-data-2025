with

pols as (
    select 
        bil_policy_key,
        bil_acct_key,
        bil_policy_id,
        policy_sym,
        policy_numb,
        policy_eff_date,
        policy_seq_numb

    from {{ ref('lkp__bil_policy_key') }}
),

trms as (
    select
        bil_policy_trm_key,
        bil_policy_key,
        bil_acct_key,
        policy_eff_date

    from {{ ref('lkp__bil_policy_trm_key') }}
),

apols as (
    select 
        associated_policy_key,
        associated_sb_policy_key as sb_policy_key,
        policy_chain_id,
        {{ five_key() }}

    from {{ ref('lkp__associated_policies') }}
),

join_policy_trm_key as (
    select
        trms.bil_policy_trm_key,


        pols.bil_policy_key,
        pols.bil_acct_key,
        pols.bil_policy_id,
        pols.policy_sym,
        pols.policy_numb,
        pols.policy_eff_date,
        pols.policy_seq_numb

    from pols
    left join trms
        on pols.bil_acct_key = trms.bil_acct_key
        and pols.bil_policy_key = trms.bil_policy_key
        and pols.policy_eff_date = trms.policy_eff_date
    
    order by
        trms.bil_policy_trm_key,
        pols.bil_policy_key
),

join_associated_policies as (
    select
        apols.associated_policy_key,
        apols.sb_policy_key,
        join_policy_trm_key.*,
        apols.policy_chain_id,
        apols.company_numb as associated_company_numb,
        apols.policy_sym as associated_policy_sym,
        apols.policy_numb as associated_policy_numb,
        apols.policy_module as associated_policy_module,
        apols.policy_eff_date as associated_policy_eff_date
        
    from join_policy_trm_key
    left join apols
        on join_policy_trm_key.policy_sym = apols.policy_sym
        and join_policy_trm_key.policy_numb = apols.policy_numb
        and join_policy_trm_key.policy_eff_date = apols.policy_eff_date
),

drop_any_policies_that_arent_in_set_of_associated_policies as (
    select *
    from join_associated_policies
    where associated_policy_key is not null
)

select *
from drop_any_policies_that_arent_in_set_of_associated_policies