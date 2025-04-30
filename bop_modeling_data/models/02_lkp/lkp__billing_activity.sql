with

raw as (
    select *
    from {{ ref('stg__cur_cb') }}
),

add_activity_transaction_key as (
    select 
        md5_number(
            try_cast(billing_acct_key as varchar)
            || try_cast(year(billing_activity_date) as varchar)
            || try_cast(month(billing_activity_date) as varchar)
            || try_cast(day(billing_activity_date) as varchar)
            || try_cast(billing_sb_policy_key as varchar)
            || try_cast(associated_policy_key as varchar)
            || try_cast(associated_sb_policy_key as varchar)
            || try_cast(billing_policy_key as varchar)
        ) as activity_trans_key,
        *

    from raw
)

select *
from add_activity_transaction_key