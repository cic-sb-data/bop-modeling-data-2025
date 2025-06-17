with

lkp as (
    {{
        generate_lookup(
            root='screngn__xcd_bil_cash_receipt',
            column_names=['bil_csh_etr_mth_cd'],
            id_col_name='bil_cash_entry_method_id'
        )
    }}
),

-- Reference table for cash entry method codes
-- Lifted from Billing Data Model 2-4-1
desc as (
    select * 
    from {{ ref('cash_entry_method_code_ref') }}
),

renamed as (
    select
        bil_cash_entry_method_id,
        bil_csh_etr_mth_cd as bil_cash_entry_method_cd,
        generated_at
    from lkp
),

join_desc as (
    select
        r.bil_cash_entry_method_id,
        r.bil_cash_entry_method_cd,
        d.bil_cash_entry_method_desc,
        r.generated_at
    from renamed r
    left join desc d    
        on r.bil_cash_entry_method_cd = d.bil_cash_entry_method_cd
)

select *
from join_desc