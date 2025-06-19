with 

lkp as (
    {{
        generate_lookup(
            root='screngn__xcd_bil_account',
            column_names=['bil_sus_dsb_rea_cd']
        )
    }}
),

renamed as (
    select 
        bil_sus_dsb_rea_id as bil_sus_disbursement_reason_id,
        bil_sus_dsb_rea_cd as bil_sus_disbursement_reason_cd,
        generated_at

    from lkp
)

select * from renamed