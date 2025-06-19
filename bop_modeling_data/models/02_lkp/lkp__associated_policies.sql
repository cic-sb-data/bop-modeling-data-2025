{{
  config(
    materialized='table',
    unique_key=['associated_policy_key', 'associated_sb_policy_key']
  )
}}

with

-- Source: Small business policies from decfile, providing sb_policy_key and policy_chain_id
sb_pol as (
    select distinct
        try_cast(sb_policy_key as uinteger) as associated_sb_policy_key,
        try_cast(policy_chain_id as uinteger) as policy_chain_id

    from {{ ref('decfile__sb_policy_lookup') }}
    order by associated_sb_policy_key
),

-- Source: Policy chain data from Modcom
pchain as (
    select distinct
        try_cast(policy_chain_id as uinteger) as policy_chain_id,
        try_cast(company_numb as utinyint) as company_numb,
        policy_sym,
        try_cast(policy_numb as uinteger) as policy_numb,
        try_cast(policy_module as uinteger) as policy_module,
        try_cast(policy_eff_date as date) as policy_eff_date

    from {{ ref('modcom__policy_chain_v3') }}
),

-- Join decfile policies (sb_policy_key) with policy chain data on policy_chain_id.
-- This links each sb_policy_key to all policies (five-key components) belonging to the same chain.
linked_policies as (
    select
        sb_pol.associated_sb_policy_key,
        pchain.policy_chain_id,
        pchain.company_numb,
        pchain.policy_sym,
        pchain.policy_numb,
        pchain.policy_module,
        pchain.policy_eff_date

    from sb_pol
    inner join pchain
        on sb_pol.policy_chain_id = pchain.policy_chain_id
),

sort_policies as (
    select *
    from linked_policies
    order by   
        associated_sb_policy_key,
        policy_sym,
        policy_numb,
        policy_eff_date
),

add_associated_policy_key as (
    select
        row_number() over() as associated_policy_key,
        *

    from sort_policies
)

select *
from add_associated_policy_key