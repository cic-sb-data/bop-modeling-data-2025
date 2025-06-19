with

lkp as (
    {{
        generate_lookup(
            root='stg__screngn__xcd_bil_account',
            column_names=['bil_collection_mth', 'bil_collection_method_desc'],
            id_col_name='bil_collection_method_id'
        )
    }}
),

renamed as (
    select
        bil_collection_method_id,
        bil_collection_mth as bil_collection_method,
        bil_collection_method_desc,
        generated_at
    from lkp
)

select *
from renamed