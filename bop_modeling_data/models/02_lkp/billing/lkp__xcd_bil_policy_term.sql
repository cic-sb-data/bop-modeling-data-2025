{%- set xcd_bil_table='policy_trm' -%}
{%- set primary_keys = [
    ('BIL_ACCOUNT_ID', 'billing_acct_id'),
    ('XCD_POLICY_ID', 'billing_policy_id'),
    ('POL_SYMBOL_CD', 'policy_sym'),
    ('POL_NBR', 'policy_numb')
    ('POL_EFFECTIVE_DT', 'policy_eff_date')
]-%}

with 

lkp as ({{ bil_table_lookup(xcd_bil_table, primary_keys) }}),
add_acct_key as ({{ add_bil_acct_key('lkp') }}),
add_policy_key as ({{ add_bil_policy_key('add_acct_key') }}),

recoded as (
    select
        bil_policy_trm_key,
        bil_policy_key,
        bil_account_key,
        policy_sym,
        policy_numb,
        policy_eff_date,
        {{ recode__sas_date_format('policy_eff_date') }} as policy_eff_date

    from add_policy_key
)

select *
from recoded
order by {{ _get_xcd_bil_key_name(xcd_bil_table) }}
