with

raw as (
    select *
    from {{ ref('stg__decfile__sb_policy_lookup') }}
)

select *
from raw