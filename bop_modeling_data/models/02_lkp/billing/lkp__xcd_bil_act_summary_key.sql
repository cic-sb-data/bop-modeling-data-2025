{%- set xcd_bil_table='act_summary' -%}
{%- set primary_keys = [
    ('BIL_ACCOUNT_ID', 'billing_acct_id'),
    ('BIL_ACY_DT', 'billing_activity_date'),
    ('BIL_ACY_SEQ', 'billing_activity_seq_numb')
] -%}

with 

lkp as ({{ bil_table_lookup(xcd_bil_table, primary_keys) }}),
add_acct_key as ({{ add_bil_account_key('lkp') }}),

recoded as (
    select
        bil_act_summary_key,
        bil_account_key,
        {{ recode__sas_date_format('billing_activity_date') }} as billing_activity_date,
        try_cast(billing_activity_seq_numb as uinteger) as billing_activity_seq_numb
    from add_acct_key
)

select *
from recoded
order by {{ _get_xcd_bil_key_name(xcd_bil_table) }}