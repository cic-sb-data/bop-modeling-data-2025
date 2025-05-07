{{
    config(materialization='ephemeral')
}}

with

policy_chain as (
    select distinct
        policy_chain_id,
        {{ five_key() }},
        count(*) over() as policy_chain__nrows

    from {{ ref('stg__modcom__policy_chain_v3') }}
    order by 
        policy_chain_id,
        {{ five_key() }}
)

select *
from policy_chain