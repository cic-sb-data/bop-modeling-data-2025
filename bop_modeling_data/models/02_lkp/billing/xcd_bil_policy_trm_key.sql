{%- set xcd_bil_table='policy_trm' -%}
{%- set primary_keys = [
    ('BIL_ACCOUNT_ID', 'bil_acct_id'),
    ('XCD_POLICY_ID', 'bil_policy_id'),
    ('POL_EFFECTIVE_DT', 'policy_eff_date')
]-%}

with 

lkp as ({{ bil_table_lookup(xcd_bil_table, primary_keys) }}),
add_acct_key as ({{ add_bil_acct_key('lkp') }}),

policy_key as (
    select
        bil_acct_key,
        bil_policy_key,
        bil_policy_id,
        policy_eff_date

    from {{ ref('xcd_bil_policy_key') }}
    where bil_policy_key is not null
),

recoded as (
    select
        bil_policy_trm_key,
        bil_policy_id,
        bil_acct_key,
        {{ recode__sas_date_format('policy_eff_date') }} as policy_eff_date

    from add_acct_key
),

join_policy_key as (
    select
        a.bil_policy_trm_key,
        b.bil_acct_key,
        b.bil_policy_key,
        a.policy_eff_date

    from recoded a
    left join policy_key b
        on a.bil_policy_id = b.bil_policy_id
        and a.policy_eff_date = b.policy_eff_date
        and a.bil_acct_key = b.bil_acct_key
),

add_row_count_before as (
    select count(*) as row_count_before 
    from join_policy_key
),

add_row_count_after as (
    select count(*) as row_count_after 
    from join_policy_key
    where bil_policy_key is not null
),

add_in_both_row_counts as (
    select
        joined.*,
        before.row_count_before,
        after.row_count_after
    from join_policy_key joined
    left join add_row_count_before before
        on 1=1
    left join add_row_count_after after
        on 1=1
    
    where   
        joined.bil_policy_key is not null
        and joined.policy_eff_date is not null
        and joined.bil_acct_key is not null
)

select *
from add_in_both_row_counts
order by {{ _get_xcd_bil_key_name(xcd_bil_table) }}
