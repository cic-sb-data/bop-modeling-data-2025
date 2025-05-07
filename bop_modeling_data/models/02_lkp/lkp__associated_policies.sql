{{
  config(
    materialized='table',
    unique_key=['associated_policy_key', 'associated_sb_policy_key'] -- Recommended: Grain is (chain_policy, sb_policy_key)
  )
}}

with

-- Source: Small business policies from decfile, providing sb_policy_key and policy_chain_id
-- Cast types early for join consistency and correctness.
sb_policies_source as (
    select distinct
        try_cast(sb_policy_key as uint32) as sb_policy_key,
        try_cast(policy_chain_id as uinteger) as policy_chain_id
    from {{ ref('stg__decfile__sb_policy_lookup') }}
    where policy_chain_id is not null
      and sb_policy_key is not null -- Ensure keys are not null
),

-- Source: Policy chain data from Modcom
-- Types are generally set in the staging model (e.g., policy_chain_id as uinteger)
policy_chain_source as (
    select distinct
        policy_chain_id, -- Expected as uinteger
        company_numb,    -- Expected as utinyint
        policy_sym,
        policy_numb,     -- Expected as uinteger
        policy_module,   -- Expected as uinteger
        policy_eff_date  -- Expected as date
    from {{ ref('stg__modcom__policy_chain_v3') }}
    where policy_chain_id is not null
      -- Add null checks for all 5 key components if policy_key() macro is sensitive
      and company_numb is not null
      and policy_sym is not null
      and policy_numb is not null
      and policy_module is not null
      and policy_eff_date is not null
),

-- Join decfile policies (sb_policy_key) with policy chain data on policy_chain_id.
-- This links each sb_policy_key to all policies (five-key components) belonging to the same chain.
linked_policies as (
    select
        sb.sb_policy_key as associated_sb_policy_key,
        pc.policy_chain_id,
        pc.company_numb,
        pc.policy_sym,
        pc.policy_numb,
        pc.policy_module,
        pc.policy_eff_date
    from sb_policies_source as sb
    inner join policy_chain_source as pc
        on sb.policy_chain_id = pc.policy_chain_id
),

-- Generate the associated_policy_key for each policy from the chain using the policy_key() macro.
-- The distinct here ensures unique combinations of (chain_policy_attributes, associated_sb_policy_key).
final_associated_policies as (
    select distinct
        {{ policy_key() }} as associated_policy_key, -- Assumes policy_key() uses contextual column names
        lp.associated_sb_policy_key,
        lp.policy_chain_id,
        lp.company_numb,
        lp.policy_sym,
        lp.policy_numb,
        lp.policy_module,
        lp.policy_eff_date
    from linked_policies as lp
)

-- Final selection of columns. Types are mostly derived from upstream staging models or early casts.
select
    associated_policy_key,    -- Type depends on policy_key() macro (e.g., varchar for hash)
    associated_sb_policy_key, -- Already uint32 from sb_policies_source
    policy_chain_id,          -- Already uinteger from sources
    company_numb,             -- Already utinyint from policy_chain_source
    policy_sym,               -- Varchar
    policy_numb,              -- Already uinteger from policy_chain_source
    policy_module,            -- Already uinteger from policy_chain_source
    policy_eff_date           -- Already date from policy_chain_source
from final_associated_policies
order by associated_policy_key, associated_sb_policy_key -- Optional: for deterministic output/easier debugging