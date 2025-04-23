with

raw as (
    select 
        cincibill_policy_key,
        policy_chain_id,
        company_numb as company_numb,
        policy_sym as policy_sym,
        policy_numb as policy_numb,
        policy_module as policy_module,
        policy_eff_date as policy_eff_date

    from read_csv_auto('{{ var("raw_csv_loc") }}/decfile.cincibill_policies.csv')
)

select * 
from raw