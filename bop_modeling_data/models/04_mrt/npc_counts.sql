with

-- IMPORTS
sb_pols as (
    select 
        policy_chain_id,
        sb_policy_key,
        lob

    from {{ ref('sb_policy_key') }}
)

select * 
from sb_pols