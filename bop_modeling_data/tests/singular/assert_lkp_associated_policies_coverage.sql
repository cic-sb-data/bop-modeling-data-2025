-- tests/singular/assert_lkp_associated_policies_coverage.sql
-- This test ensures that every sb_policy_key from the source decfile lookup
-- that has a policy_chain_id is represented in lkp__associated_policies.
-- It also ensures that every policy_chain_id in lkp__associated_policies
-- exists in the source policy_chain model.

with decfile_sb_policies as (
    select distinct
        try_cast(sb_policy_key as uint32) as sb_policy_key,
        try_cast(policy_chain_id as uinteger) as policy_chain_id
    from {{ ref('stg__decfile__sb_policy_lookup') }}
    where policy_chain_id is not null
      and sb_policy_key is not null
),

modcom_policy_chains as (
    select distinct
        policy_chain_id -- Expected as uinteger
    from {{ ref('stg__modcom__policy_chain_v3') }}
    where policy_chain_id is not null
),

lkp_associated as (
    select distinct
        associated_sb_policy_key,
        policy_chain_id
    from {{ ref('lkp__associated_policies') }}
),

-- Check 1: All relevant sb_policy_keys from decfile are in lkp__associated_policies
decfile_keys_missing_in_lkp as (
    select d.sb_policy_key
    from decfile_sb_policies d
    left join lkp_associated lkp
        on d.sb_policy_key = lkp.associated_sb_policy_key
    where lkp.associated_sb_policy_key is null
),

-- Check 2: All policy_chain_ids in lkp__associated_policies exist in modcom_policy_chains
lkp_chain_ids_missing_in_modcom as (
    select lkp.policy_chain_id
    from lkp_associated lkp
    left join modcom_policy_chains mpc
        on lkp.policy_chain_id = mpc.policy_chain_id
    where mpc.policy_chain_id is null and lkp.policy_chain_id is not null -- lkp.policy_chain_id should not be null by model logic
),

-- Check 3: Every associated_sb_policy_key in lkp_associated_policies must have at least one associated_policy_key
-- This is implicitly handled by the grain of lkp_associated_policies, but an explicit check can be added if needed.
-- For now, we assume the unique key test on (associated_policy_key, associated_sb_policy_key) covers this.

final_issues as (
    select 'decfile_keys_missing_in_lkp' as issue_type, count(*) as issue_count from decfile_keys_missing_in_lkp
    union all
    select 'lkp_chain_ids_missing_in_modcom' as issue_type, count(*) as issue_count from lkp_chain_ids_missing_in_modcom
)

select issue_type, issue_count
from final_issues
where issue_count > 0
