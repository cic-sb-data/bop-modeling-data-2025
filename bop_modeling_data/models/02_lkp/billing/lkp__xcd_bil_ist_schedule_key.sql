{%- set xcd_bil_table='ist_schedule' -%}
{%- set primary_keys = [
    ('BIL_ACCOUNT_ID', 'bil_acct_id'),
    ('XCD_POLICY_ID', 'bil_policy_id'),
    ('BIL_SEQ_NBR', 'bil_seq_numb')
]-%}

with 

lkp as ({{ bil_table_lookup(xcd_bil_table, primary_keys) }}),
add_acct_key as ({{ add_bil_acct_key('lkp') }}),

policy_key as (
    select
        bil_policy_key,
        bil_policy_id

    from {{ ref('lkp__xcd_bil_policy_key') }}
),

recoded as (
    select
        bil_ist_schedule_key,
        bil_policy_id,
        bil_acct_key,
        try_cast(bil_seq_numb as uinteger) as bil_seq_numb 

    from add_policy_key
),

joined as (
    select
        a.bil_ist_schedule_key,
        b.bil_acct_key,
        b.bil_policy_key,
        a.bil_seq_numb

    from recoded a
    left join policy_key b
        on a.bil_policy_id = b.bil_policy_id
        and a.bil_acct_key = b.bil_acct_key
)

select *
from recoded
where bil_seq_numb is not null
order by {{ _get_xcd_bil_key_name(xcd_bil_table) }}
