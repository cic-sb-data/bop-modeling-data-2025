with

raw as (
    select
        sb_policy_key,
        policy_chain_id,
        lob,
        company_numb,
        policy_sym,
        policy_numb,
        policy_module,
        policy_eff_date

    from {{ ref('raw__decfile__sb_policy_lookup') }}
)

select *
from raw