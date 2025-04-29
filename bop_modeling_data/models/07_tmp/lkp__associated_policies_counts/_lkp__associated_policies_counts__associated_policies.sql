{{
    config(materialization='ephemeral')
}}

with

filtered_policy_chains as (
    select * exclude (filtered_policy_chains__nrows)
    from {{ ref('_lkp__associated_policies_counts__filtered_policy_chains') }}
),

associated_policies as (
    select distinct
        policy_chain_policy_key,
        associated_sb_policy_key,
        policy_chain_id,
        {{ five_key() }},
        count(*) over() as associated_policies__nrows

    from filtered_policy_chains
    order by 
        associated_sb_policy_key,
        policy_chain_id,
        {{ five_key() }}
)

select *
from associated_policies
