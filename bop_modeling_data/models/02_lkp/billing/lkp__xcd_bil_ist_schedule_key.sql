{%- set xcd_bil_table='ist_schedule' -%}
{%- set primary_keys = [
    ('BIL_ACCOUNT_ID', 'billing_acct_id'),
    ('XCD_POLICY_ID', 'billing_policy_id'),
    ('BIL_SEQ_NBR', 'billing_seq_numb')
]-%}

with 

lkp as ({{ bil_table_lookup(xcd_bil_table, primary_keys) }}),
add_acct_key as ({{ add_bil_acct_key('lkp') }}),
add_policy_key as ({{ add_bil_policy_key('add_acct_key') }}),

recoded as (
    select
        bil_ist_schedule_key,
        bil_policy_key,
        bil_account_key,
        try_cast(billing_seq_numb as uinteger) as billing_seq_numb 

    from add_policy_key
)

select *
from recoded
order by {{ _get_xcd_bil_key_name(xcd_bil_table) }}
