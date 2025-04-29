{{
    config(materialization='ephemeral')
}}

with

associated_policies as (
    select * exclude (associated_policies__nrows)
    from {{ ref('_lkp__associated_policies_counts__associated_policies') }}
),

add_final_associated_policy_key as (
    select 
        policy_chain_policy_key as associated_policy_key,
        associated_sb_policy_key,
        policy_chain_id,
        {{ five_key() }},
        count(*) over() as add_final_associated_policy_key__nrows 

    from associated_policies
    order by 
        associated_sb_policy_key,
        policy_chain_id,
        {{ five_key() }}
)

select *
from add_final_associated_policy_key
