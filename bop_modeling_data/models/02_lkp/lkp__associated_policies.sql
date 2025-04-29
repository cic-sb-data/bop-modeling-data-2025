{{
  config(
    materialized='table',
    unique_key='associated_policy_key'
)}}

with

sb_policies as (
    select 
        *,
        count(*) over() as sb_policies__nrows

    from {{ ref('stg__decfile__sb_policy_lookup') }}
),

policy_chain as (
    select distinct
        {{ generate_policy_key() }} as policy_chain_policy_key,
        policy_chain_id,
        {{ five_key() }},
        count(*) over() as policy_chain__nrows

    from {{ ref('stg__modcom__policy_chain_v3') }}
    order by 
        policy_chain_id,
        {{ five_key() }}
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
),


get_counts as (
    select 'sb_policies' as cte, sb_policies__nrows as cnt from sb_policies
    union all 
        select 'policy_chain' as cte, policy_chain__nrows as cnt from policy_chain
    union all   
        select 'filtered_policy_chains' as cte, filtered_policy_chains__nrows as cnt from filtered_policy_chains
    union all 
        select 'associated_policies' as cte, associated_policies__nrows as cnt from associated_policies
    union all 
        select 'add_final_associated_policy_key' as cte, add_final_associated_policy_key__nrows as cnt from add_final_associated_policy_key
),

check_for_duplicated_policies as (
    select 
        *,
        case 
            when count(*) over(partition by associated_sb_policy_key, {{ five_key() }}) > 1 
                then 1
            else 0
        end as is_gt1_five_key_in_table

    from add_final_associated_policy_key
),

finalize_types as (
    select
        associated_policy_key,
        try_cast(associated_sb_policy_key as uint32) as associated_sb_policy_key,
        policy_chain_id,
        company_numb,
        policy_sym,
        policy_numb,
        policy_module,
        try_cast(policy_eff_date as date) as policy_eff_date,
        try_cast(is_gt1_five_key_in_table as uint8) as is_gt1_five_key_in_table

    from check_for_duplicated_policies
)

select *
from get_counts