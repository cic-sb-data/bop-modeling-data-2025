with

sb_policies as (
    select * 
    from {{ ref('_lkp__associated_policies_counts__sb_policies') }}
),

policy_chain as (
    select * 
    from {{ ref('_lkp__associated_policies_counts__policy_chain') }}
),

filtered_policy_chains as (
    select * 
    from {{ ref('_lkp__associated_policies_counts__filtered_policy_chains') }}
),

associated_policies as (
    select * 
    from {{ ref('_lkp__associated_policies_counts__associated_policies') }}
),

add_final_associated_policy_key as (
    select * 
    from {{ ref('_lkp__associated_policies_counts__add_final_associated_policy_key') }}
),

get_counts as (
    select 1 as ord, 'sb_policies' as cte, sb_policies__nrows as cnt from sb_policies
    union all 
        select 2 as ord, 'policy_chain' as cte, policy_chain__nrows as cnt from policy_chain
    union all   
        select 3 as ord, 'filtered_policy_chains' as cte, filtered_policy_chains__nrows as cnt from filtered_policy_chains
    union all 
        select 4 as ord, 'associated_policies' as cte, associated_policies__nrows as cnt from associated_policies
    union all 
        select 5 as ord, 'add_final_associated_policy_key' as cte, add_final_associated_policy_key__nrows as cnt from add_final_associated_policy_key
),

check_for_duplicated_policies as (
    select 
        *,
        case 
            when count(*) over(partition by associated_sb_policy_key, {{ five_key() }}) > 1 
                then 1
            else 0
        end as is_gt1_five_key_in_table

    from get_counts
)

select  
    cte,
    cnt,
    sum(is_gt1_five_key_in_table) as n_sb_policy_keys_with_gt1_key_in_associated_policy_tbl


from check_for_duplicated_policies
group by 
    cte,
    cnt 

order by ord
