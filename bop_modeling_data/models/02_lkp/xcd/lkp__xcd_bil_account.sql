with

raw as (
    select distinct bil_account_id
    from {{ ref('stg__screngn__xcd_bil_account') }}
    order by bil_account_id
),

add_acct_key as (
    select 
        row_number() over() as billing_account_key,
        *

    from raw
)

select *
from add_acct_key