with

bil_activity as (select * from {{ ref('stg__screngn__xcd_bil_act_summary') }})


select * from bil_activity
