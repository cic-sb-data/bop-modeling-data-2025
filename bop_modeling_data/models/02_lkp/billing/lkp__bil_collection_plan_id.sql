with

lkp as (
    {{
        generate_lookup(
            root='screngn__xcd_bil_account',
            column_names=['bil_collection_pln', 'bil_collection_pln_desc'],
            id_col_name='bil_collection_plan_id'
        )
    }}
),

renamed as (
    select
        bil_collection_plan_id,
        bil_collection_pln as bil_collection_plan,
        bil_collection_pln_desc as bil_collection_plan_desc,
        generated_at
    from lkp
)

select *
from renamed