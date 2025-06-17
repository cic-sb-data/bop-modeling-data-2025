with 

lkp as (
    {{
        generate_lookup(
            root='screngn__xcd_bil_account',
            column_names=['bil_sus_dsb_rea_cd']
        )
    }}
)

select * from lkp

