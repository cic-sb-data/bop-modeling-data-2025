with

raw as (
    select distinct
        policy_chain_id,
        company_numb,
        policy_sym,
        policy_numb,
        policy_module,
        policy_eff_date


    from {{ ref('raw__modcom__policy_chain_v3') }}
),

add_keys as (
    select         
        md5_number(try_cast(company_numb as varchar) 
            || policy_sym 
            || try_cast(policy_numb as varchar) 
            || try_cast(policy_module as varchar)
            || try_cast(policy_eff_date as varchar)) as five_key_hash,
        md5_number(policy_sym 
            || try_cast(policy_numb as varchar) 
            || try_cast(policy_eff_date as varchar)) as three_key_hash,
        *

    from raw
    order by
        five_key_hash,
        three_key_hash
)

select *
from add_keys