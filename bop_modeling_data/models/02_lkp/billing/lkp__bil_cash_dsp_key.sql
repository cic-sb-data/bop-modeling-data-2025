{%- set xcd_bil_table='cash_dsp' -%}
{%- set primary_keys = [
    ('BIL_ACCOUNT_ID', 'bil_acct_id'),
    ('BIL_DTB_DT', 'bil_distribution_date'),
    ('BIL_DTB_SEQ_NBR', 'bil_distribution_seq_numb'),
    ('BIL_DSP_SEQ_NBR', 'bil_disposition_seq_numb')
]-%}

with 

lkp as ({{ bil_table_lookup(xcd_bil_table, primary_keys) }}),
add_acct_key as ({{ add_bil_acct_key('lkp') }}),

recoded as (
    select
        bil_cash_dsp_key,
        bil_acct_key,
        {{ recode__sas_date_format('bil_distribution_date') }} as bil_distribution_date,
        try_cast(bil_distribution_seq_numb as uinteger) as bil_distribution_seq_numb,
        try_cast(bil_disposition_seq_numb as uinteger) as bil_disposition_seq_numb
    from add_acct_key
)

select *
from recoded
order by {{ _get_xcd_bil_key_name(xcd_bil_table) }}