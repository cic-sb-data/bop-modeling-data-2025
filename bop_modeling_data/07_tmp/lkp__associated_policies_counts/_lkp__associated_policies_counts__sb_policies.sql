{{
    config(materialization='table')
}}

with

sb_policies as (
    select 
        *,
        count(*) over() as sb_policies__nrows

    from {{ ref('stg__decfile__sb_policy_lookup') }}
)

select *
from sb_policies