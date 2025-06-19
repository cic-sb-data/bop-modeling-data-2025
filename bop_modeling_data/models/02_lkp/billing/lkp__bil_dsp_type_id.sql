with

lkp as (
    {{
        generate_lookup(
            root='screngn__xcd_bil_cash_dsp',
            column_names=['bil_dsp_type_cd'],
            id_col_name='bil_dsp_type_id'
        )
    }}
),

renamed as (
    select
        bil_dsp_type_id,
        bil_dsp_type_cd,
        generated_at
    from lkp
)

select *
from renamed