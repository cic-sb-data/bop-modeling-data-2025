with

lkp as (
    {{
        generate_lookup(
            root='stg__screngn__xcd_bil_policy',
            column_names=['cur_bil_plan_cd', 'current_billing_plan'],
            id_col_name='bil_plan_id'
        )
    }}
),

recoded as (
    select 
        bil_plan_id,
        cur_bil_plan_cd as bil_plan_cd,
        case
            when lower(cur_bil_plan_cd) like '%an%' then 'Annual'
            when lower(cur_bil_plan_cd) like '%mo%' then 'Monthly'
            when lower(cur_bil_plan_cd) like '%semi%' then 'Semi-Annual'
            when lower(cur_bil_plan_cd) like '%anpp%' then 'Annual Pre-Payment'
            when lower(cur_bil_plan_cd) like '%qt%' then 'Quarterly'
            when lower(cur_bil_plan_cd) like '%bi%' then 'Bi-Annual'
            when lower(cur_bil_plan_cd) like '%25su%' then '25% Surcharge'
            when lower(cur_bil_plan_cd) like '%anbd%' then 'Annual Budget'
            else 'Unknown'
        end as bil_plan_desc,
        generated_at
    from lkp
)


select *
from recoded
order by bil_plan_id