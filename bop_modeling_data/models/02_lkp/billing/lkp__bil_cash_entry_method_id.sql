with

lkp as (
    {{
        generate_lookup(
            root='screngn__xcd_bil_cash_receipt',
            column_names=['bil_csh_etr_mth_cd']
        )
    }}
),

-- Reference table for cash entry method codes
-- Lifted from Billing Data Model 2-4-1
add_desc as (
    select 'A' as bil_cash_entry_method_cd, 'EFT (Electronic funds transfer)' as bil_cash_entry_method_desc
    union all select 'C', 'Non-cash credit created as part of third party reconciliation'
    union all select 'E', 'EFT credit card'
    union all select 'G', 'Online Entry'
    union all select 'H', 'Credit Card Entry'
    union all select 'I', 'Tolerance write-off'
    union all select 'S', 'Statement'
    union all select 'T', 'Tape processed through third party cash reconciliation'
    union all select '1', 'Agent ACH/Paper'
    union all select '2', 'Insured Paper'
    union all select '3', 'Insured one-time ACH'
),

renamed as (
    select
        bil_csh_etr_mth_id as bil_cash_entry_method_id,
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
    left join add_desc d    
        on r.bil_cash_entry_method_cd = d.bil_cash_entry_method_cd
)

select *
from join_desc