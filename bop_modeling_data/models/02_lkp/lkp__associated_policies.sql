{{
  config(
    materialized='table',
    unique_key='associated_policy_key'
)}}

with

tmp_tbl as (
    select *
    from {{ ref('_lkp__associated_policies_counts') }}
),

check_for_duplicated_policies as (
    select 
        *,
        case 
            when count(*) over(partition by associated_sb_policy_key, {{ five_key() }}) > 1 
                then 1
            else 0
        end as is_gt1_five_key_in_table

    from tmp_tbl
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
        try_cast(is_gt1_five_key_in_table as uint8) as __is_gt1_five_key_in_table

    from check_for_duplicated_policies
)

select *
from finalize_types