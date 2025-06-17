with

lkp as (
    {{
        generate_lookup(
            root='screngn__xcd_bil_cash_dsp',
            column_names=['bil_crg_type_cd'],
            id_col_name='bil_crg_type_id'
        )
    }}
),

renamed as (
    select
        bil_crg_type_id as bil_charge_type_id,
        bil_crg_type_cd as bil_charge_type_code,
        generated_at
    from lkp
),

add_desc as (
    select 
        bil_charge_type_id,
        bil_charge_type_code,
        case 
            when bil_charge_type_code='S' then 'Service'
            when bil_charge_type_code='P' then 'Penalty'
            when bil_charge_type_code='L' then 'Late fee'
            when bil_charge_type_code='D' then 'Down Payment fee'
            else 'Unknown Charge Type'
        end as bil_charge_type_desc,
        generated_at

    from renamed
)

select *
from add_desc