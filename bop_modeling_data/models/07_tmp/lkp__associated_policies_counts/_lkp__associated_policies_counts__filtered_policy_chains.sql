{{
    config(materialization='ephemeral')
}}

with

sb_policies as (
    select * exclude (sb_policies__nrows)
    from {{ ref('_lkp__associated_policies_counts__sb_policies') }}
),

policy_chain as (
    select * exclude (policy_chain__nrows)
    from {{ ref('_lkp__associated_policies_counts__policy_chain') }}
),

filtered_policy_chains as (
    select 
        sb_policies.sb_policy_key as associated_sb_policy_key,
        policy_chain.*,
        count(*) over() as filtered_policy_chains__nrows

    from policy_chain
    inner join sb_policies
        on policy_chain.policy_chain_id = sb_policies.policy_chain_id

    where policy_chain.policy_chain_id is not null
)

select *
from filtered_policy_chains
