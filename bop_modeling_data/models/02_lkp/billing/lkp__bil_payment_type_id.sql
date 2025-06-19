with

lkp as (
    {{
        generate_lookup(
            root='screngn__xcd_bil_cash_receipt',
            column_names=['payment_type'],
        )
    }}
),

renamed as (
    select
        payment_type_id as bil_payment_type_id,
        payment_type as bil_payment_type,
        generated_at
    from lkp
)

select *
from renamed