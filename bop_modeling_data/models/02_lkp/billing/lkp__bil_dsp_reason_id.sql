with

lkp as (
    {{
        generate_lookup(
            root='stg__screngn__xcd_bil_cash_dsp',
            column_names=['bil_dsp_reason_cd'],
            id_col_name='bil_dsp_reason_id'
        )
    }}
),

renamed as (
    select
        bil_dsp_reason_id,
        bil_dsp_reason_cd,
        generated_at
    from lkp
)

select *
from renamed