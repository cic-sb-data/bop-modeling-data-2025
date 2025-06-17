with

lkp as (
    {{
        generate_lookup(
            root='screngn__xcd_bil_cash_receipt',
            column_names=['payment_type'],
            id_col_name='bil_payment_type_id'
        )
    }}
),

renamed as (
    select
        bil_payment_type_id,
        payment_type as bil_payment_type,
        generated_at
    from lkp
)

select *
from renamed