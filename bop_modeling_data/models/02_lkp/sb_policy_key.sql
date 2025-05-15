with

raw as (
    select *
    from {{ ref('decfile__sb_policy_lookup') }}
)

select *
from raw