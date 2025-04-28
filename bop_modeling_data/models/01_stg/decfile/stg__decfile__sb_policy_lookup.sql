with

raw as (
    select *
    from {{ ref('raw__decfile__sb_policy_lookup') }}
)

select *
from raw