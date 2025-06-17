with
lkp as (
    {{
        generate_lookup(
            root='screngn__xcd_bil_account',
            column_names=['bat_cash_status_cd']
        )
    }}
),

add_desc as (
    select
        *,
        case
            when bat_cash_status_cd = 'A' then 'Active'
            when bat_cash_status_cd = 'D' then 'Suspended/Hold Auto Disbursement'
            else 'Unknown Code'
        end as bat_cash_status_desc
        
    from lkp
),

renamed as (
    select
        bat_cash_status_id as bil_acct_cash_status_id,
        bat_cash_status_cd as bil_acct_cash_status_cd,
        bat_cash_status_desc as bil_acct_cash_status_desc,
        generated_at
    from add_desc
)

select *
from renamed
order by bil_acct_cash_status_id