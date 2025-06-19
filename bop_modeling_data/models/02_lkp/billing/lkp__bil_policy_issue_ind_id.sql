with

lkp as (
    {{
        generate_lookup(
            root='stg__screngn__xcd_bil_policy',
            column_names=['bil_issue_ind', 'bil_policy_issue_ind_desc'],
            id_col_name='bil_policy_issue_ind_id'
        )
    }}
),

recoded as (
    select 
        bil_policy_issue_ind_id,
        bil_issue_ind as bil_policy_issue_ind_cd,
        bil_policy_issue_ind_desc as bil_policy_issue_ind_desc,
        generated_at
    from lkp
)


select *
from recoded
order by bil_policy_issue_ind_id