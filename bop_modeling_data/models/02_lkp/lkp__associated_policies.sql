{{
  config(
    materialized='table',
    unique_key='associated_policy_key'
)}}

with

sb_policies as (
    select *
    from {{ ref('stg__decfile__sb_policy_lookup') }}
),

policy_chain as (
    select *
    from {{ ref('stg__modcom__policy_chain') }}
),

filtered_policy_chains as (
    select 
        sb_policies.sb_policy_key as associated_sb_policy_key,
        policy_chain.*,

    from policy_chain
    inner join sb_policies
        on policy_chain.policy_chain_id = sb_policies.policy_chain_id
    where policy_chain.policy_chain_id is not null
),

associated_policies as (
    select distinct
        associated_sb_policy_key,
        policy_chain_id,
        {{ five_key() }}

    from filtered_policy_chains
    order by 
        associated_sb_policy_key,
        policy_chain_id,
        {{ five_key() }}
),

add_final_associated_policy_key as (
    select 
        row_number() over() as associated_policy_key,
        associated_sb_policy_key,
        policy_chain_id,
        {{ five_key() }}

    from associated_policies
    order by 
        associated_sb_policy_key,
        policy_chain_id,
        {{ five_key() }}
),

check_for_duplicated_policies as (
    select 
        *,
        case 
            when count(*) over(partition by {{ five_key() }}) > 1 
                then 1
            else 0
        end as is_gt1_five_key_in_table

    from add_final_associated_policy_key
)

select *
from check_for_duplicated_policies