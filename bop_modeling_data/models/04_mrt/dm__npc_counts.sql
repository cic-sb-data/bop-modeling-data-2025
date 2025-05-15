with

-- IMPORTS
sb_pols as (
    select 
        policy_chain_id,
        sb_policy_key,
        lob

    from {{ ref('lkp__sb_policy_key') }}
)

select * 
from sb_pols