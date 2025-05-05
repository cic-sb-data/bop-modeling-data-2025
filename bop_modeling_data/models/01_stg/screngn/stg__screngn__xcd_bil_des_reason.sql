with

raw as (
    select *
    from {{ ref('raw__screngn__xcd_bil_des_reason') }}
)

select *
from raw