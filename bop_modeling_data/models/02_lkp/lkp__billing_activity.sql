with

{{ with_ref('stg__cur_cb', 'raw') }},
{{ with_ref('lkp__dates', 'dates') }},

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
        associated_policy_key,
        associated_sb_policy_key,
        billing_activity_date,
        billing_activity_amt

    from raw
    order by 
        associated_policy_key,
        associated_sb_policy_key,
        billing_activity_date
)

select *
from add_activity_transaction_key