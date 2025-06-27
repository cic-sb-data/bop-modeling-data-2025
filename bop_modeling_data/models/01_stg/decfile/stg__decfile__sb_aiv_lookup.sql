with

raw as (
    select *
    from {{ ref('raw__decfile__sb_aiv_lookup') }}
)

select *
from raw