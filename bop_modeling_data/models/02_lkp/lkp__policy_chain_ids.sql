with

raw as (
    select 
        policy_chain_id,
        count(*) as n_sb_policies_for_policy_chain_id

    from {{ ref('stg__decfile__sb_policy_lookup') }}
    group by policy_chain_id
)

select *
from raw
order by policy_chain_id