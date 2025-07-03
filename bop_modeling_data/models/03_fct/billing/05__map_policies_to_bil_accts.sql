-- This model maps policies to billing accounts, following the SAS logic for pol_s2n_acct and all_bil_acct_for_s2n.

with

policies as (
    select
        policy_chain_id,
        associated_policy_key,
        sb_policy_key,
        bil_policy_key,
        bil_policy_trm_key,
        bil_acct_key,
        associated_company_numb as company_numb,
        associated_policy_sym as policy_sym,
        associated_policy_numb as policy_numb,
        associated_policy_module as policy_module,
        associated_policy_eff_date as policy_eff_date
        
    from {{ ref('lkp__bil_policy') }}
)


select *
from policies
