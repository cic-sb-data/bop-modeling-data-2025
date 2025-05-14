{%- set xcd_bil_table='policy' -%}
{%- set primary_keys = [
    ('BIL_ACCOUNT_ID', 'billing_acct_id'),
    ('XCD_POLICY_ID', 'billing_policy_id')
]-%}

with 

lkp as ({{ bil_table_lookup(xcd_bil_table, primary_keys) }}),
add_acct_key as ({{ add_bil_account_key('lkp') }}),

recoded as (
    select
        {{ _get_xcd_bil_key_name(xcd_bil_table) }},
        bil_account_key,
        billing_policy_id
    from add_acct_key
)

select *
from recoded
order by {{ _get_xcd_bil_key_name(xcd_bil_table) }}
