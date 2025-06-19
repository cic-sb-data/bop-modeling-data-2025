with

lkp as (
    {{
        generate_lookup(
            root='stg__screngn__xcd_bil_account',
            column_names=['bat_status_cd', 'bat_status_desc'],
            id_col_name='bil_acct_status_id'
        )
    }}
),

renamed as (
    select 
        bil_acct_status_id,
        bat_status_cd as bil_acct_status_cd,
        bat_status_desc as bil_acct_status_desc,
        generated_at
    from lkp
)

select *
from renamed