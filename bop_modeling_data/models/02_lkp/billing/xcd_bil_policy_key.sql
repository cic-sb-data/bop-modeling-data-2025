{%- set xcd_bil_table='policy' -%}
{%- set primary_keys = [
    ('BIL_ACCOUNT_ID', 'bil_acct_id'),
    ('XCD_POLICY_ID', 'bil_policy_id')
]-%}

with 

lkp as ({{ bil_table_lookup(xcd_bil_table, primary_keys) }}),
add_acct_key as ({{ add_bil_acct_key('lkp') }}),

recoded as (
    select
        {{ _get_xcd_bil_key_name(xcd_bil_table) }},
        bil_acct_key,
        bil_policy_id
    from add_acct_key
)

select *
from recoded
order by {{ _get_xcd_bil_key_name(xcd_bil_table) }}
