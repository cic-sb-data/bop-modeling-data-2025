with

{{ with_ref('fct__billing_activity', 'raw') }},

drop_cols as (
    select distinct 
        activity_trans_key, 
        billing_activity_date

    from raw
    order by 
        activity_trans_key, 
        billing_activity_date
),

min_date_is_the_first_billing_activity_date as (
    select
        activity_trans_key,
        min(billing_activity_date) as first_billing_activity_date

    from drop_cols
    group by activity_trans_key
    order by activity_trans_key
)

select *
from min_date_is_the_first_billing_activity_date 