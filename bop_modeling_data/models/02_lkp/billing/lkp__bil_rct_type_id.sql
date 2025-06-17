with

lkp as (
    {{
        generate_lookup(
            root='screngn__xcd_bil_cash_receipt',
            column_names=['bil_rct_type_cd'],
            id_col_name='bil_rct_type_id'
        )
    }}
),

renamed as (
    select
        bil_rct_type_id,
        bil_rct_type_cd,
        generated_at
    from lkp
)

select *
from renamed