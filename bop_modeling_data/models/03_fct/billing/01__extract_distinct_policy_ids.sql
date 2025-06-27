-- Extract distinct policy ids from the policy lookup staging model.

with 

raw as (
    select * from {{ ref('stg__decfile__sb_policy_lookup') }}
),
selected_columns as (
    select
        policy_chain_id,
        sb_policy_key,
        lob,
        company_numb,
        policy_sym,
        policy_numb,
        policy_module,
        policy_eff_date
    from raw
)

select * from selected_columns