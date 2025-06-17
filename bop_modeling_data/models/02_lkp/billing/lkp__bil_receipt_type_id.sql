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

desc_lkp as (
    select 'CP' as bil_receipt_type_cd, 'Credit Card Cash with Application' as bil_receipt_type_desc,
    union all select 'CR' as bil_receipt_type_cd, 'Credit Cash' as bil_receipt_type_desc,
    union all select 'CS' as bil_receipt_type_cd, 'Credit Statement' as bil_receipt_type_desc,
    union all select 'CY' as bil_receipt_type_cd, 'Credit Card Payment' as bil_receipt_type_desc,
    union all select 'EC' as bil_receipt_type_cd, 'EFT Credit Card' as bil_receipt_type_desc,
    union all select 'EY' as bil_receipt_type_cd, 'EFT Assumed Payment' as bil_receipt_type_desc,
    union all select 'PA' as bil_receipt_type_cd, 'Cash with Application' as bil_receipt_type_desc,
    union all select 'PY' as bil_receipt_type_cd, 'Installment Payment' as bil_receipt_type_desc,
    union all select 'IW' as bil_receipt_type_cd, 'Underpay Write-off' as bil_receipt_type_desc,
    union all select 'CM' as bil_receipt_type_cd, 'Commission Payment Cash' as bil_receipt_type_desc,
    union all select 'AA' as bil_receipt_type_cd, 'One-time ACH' as bil_receipt_type_desc,
    union all select 'AI' as bil_receipt_type_cd, 'One-time ACH - Internet' as bil_receipt_type_desc
),

renamed as (
    select
        bil_rct_type_id as bil_receipt_type_id,
        bil_rct_type_cd as bil_receipt_type_cd,
        generated_at
    from lkp
),

join_desc as (
    select
        r.bil_receipt_type_id,
        r.bil_receipt_type_cd,
        d.bil_receipt_type_desc,
        r.generated_at
    from renamed r
    left join desc_lkp d 
        on r.bil_receipt_type_cd = d.bil_receipt_type_cd
    order by r.bil_receipt_type_id
)

select *
from join_desc