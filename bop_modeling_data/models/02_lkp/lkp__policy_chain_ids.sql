with

raw as (
    select 
        policy_chain_id,
        count(*) as n_sb_policies_for_policy_chain_id

    from {{ ref('stg__decfile__sb_policy_lookup') }}
    group by policy_chain_id
),

pchain as (
    select distinct
        policy_chain_id,
        {{ five_key() }}

    from {{ ref('stg__modcom__policy_chain_v3') }}

    order by 
        policy_chain_id,
        {{ five_key() }}
),

join_pchain as (
    select 
        raw.*,
        pchain.* exclude (policy_chain_id)

    from raw 
    inner join pchain 
        on raw.policy_chain_id = pchain.policy_chain_id
),

count_total_policies_associated_with_policy_chain as (
    select 
        policy_chain_id,
        n_sb_policies_for_policy_chain_id,
        count(*) as n_total_policies_for_policy_chain_id

    from join_pchain
    group by 
        policy_chain_id,
        n_sb_policies_for_policy_chain_id

    order by policy_chain_id
)

select *
from count_total_policies_associated_with_policy_chain