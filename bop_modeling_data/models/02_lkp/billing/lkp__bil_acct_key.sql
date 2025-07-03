with

raw as (
    select distinct BIL_ACCOUNT_ID as bil_acct_id,
    from {{ ref('raw__screngn__xcd_bil_account') }}
    order by bil_acct_id
),

add_acct_key as (
    select 
        row_number() over() as bil_acct_key,
        bil_acct_id
    from raw
),

sort_table as (
    select *
    from add_acct_key
    order by bil_acct_key
)

select *
from sort_table