{%- set xcd_bil_table='cash_receipt' -%}
{%- set primary_keys = [
    ('BIL_ACCOUNT_ID', 'billing_acct_id'),
    ('BIL_DTB_DT', 'billing_distribution_date'),
    ('BIL_DTB_SEQ_NBR', 'billing_distribution_seq_numb')
]-%}

with 

lkp as ({{ billing_table_lookup(xcd_bil_table, primary_keys) }}),
add_acct_key as ({{ add_bil_account_key('lkp') }}),

recoded as (
    select
        bil_cash_receipt_key,
        bil_account_key,
        {{ recode__sas_date_format('billing_distribution_date') }} as billing_distribution_date,
        try_cast(billing_distribution_seq_numb as uinteger) as billing_distribution_seq_numb
    from add_acct_key
)

select *
from recoded
order by {{ _get_xcd_bil_key_name(xcd_bil_table) }}
