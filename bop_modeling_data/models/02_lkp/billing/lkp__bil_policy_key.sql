{%- set xcd_bil_table='policy' -%}
{%- set primary_keys = [
    ('BIL_ACCOUNT_ID', 'bil_acct_id'),
    ('XCD_POLICY_ID', 'bil_policy_id'),
    ('POL_SYMBOL_CD', 'policy_sym'),
    ('POL_NBR', 'policy_numb')
]-%}

with 

lkp as ({{ bil_table_lookup(xcd_bil_table, primary_keys) }}),
add_acct_key as ({{ add_bil_acct_key('lkp') }}),


recoded as (
    select 
        {{ _get_key_name(xcd_bil_table) }},
        bil_acct_key,
        bil_policy_id,
        policy_sym,
        try_cast(policy_numb as uinteger) as policy_numb

    from add_acct_key
),

eff_dates as (
    select distinct
        xcd_policy_id as bil_policy_id,
        {{ recode__sas_date_format('POL_EFFECTIVE_DT') }} as policy_eff_date

    from {{ ref('raw__screngn__xcd_bil_policy_trm') }}
),

join_eff_dates as (
    select distinct
        recoded.*,
        eff_dates.policy_eff_date

    from recoded
    left join eff_dates
        on recoded.bil_policy_id = eff_dates.bil_policy_id
),

add_policy_seq_numb as (
    select
        *,
        row_number() over(
            partition by {{ _get_key_name(xcd_bil_table) }}
            order by policy_eff_date
        ) as policy_seq_numb
        
    from join_eff_dates
)


select *
from add_policy_seq_numb