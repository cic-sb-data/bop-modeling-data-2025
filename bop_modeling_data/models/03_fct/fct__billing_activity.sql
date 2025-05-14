with

{{ with_ref('lkp__dates', 'dates') }},

add_activity_transaction_key as (
    select 
        *
    from dates
)

select *
from add_activity_transaction_key