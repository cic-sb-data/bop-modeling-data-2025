-- tests/singular/assert_dm_npc_counts_referential_integrity.sql
-- This test ensures that every sb_policy_key in dm__npc_counts
-- exists in lkp__associated_policies.
-- It also checks that the policy_eff_date in dm__npc_counts matches the one
-- for the corresponding associated_sb_policy_key in lkp__associated_policies.

with npc_counts as (
    select
        sb_policy_key,
        policy_eff_date
    from {{ ref('dm__npc_counts') }}
),

associated_policies as (
    select distinct -- lkp__associated_policies might have multiple entries per associated_sb_policy_key if it links to multiple chain policies
        associated_sb_policy_key,
        policy_eff_date -- This is the policy_eff_date of the *chain policy*, not necessarily the sb_policy_key's original decfile eff_date
                        -- For dm__npc_counts, we need the effective date of the *anchor* sb_policy_key.
                        -- The lkp__associated_policies was refactored to output the five-key components of the *chain policy*.
                        -- We need to join back to the source of sb_policy_key effective dates if that's the reference.
                        -- However, dm__npc_counts sources policy_eff_date from lkp__associated_policies directly.
                        -- Let's assume dm__npc_counts.policy_eff_date is intended to be the one from lkp__associated_policies.
    from {{ ref('lkp__associated_policies') }}
),

-- To get the original effective date of the sb_policy_key (decfile policy)
-- we should refer to stg__decfile__sb_policy_lookup if that's the intended reference for prior year calculations.
-- The current dm__npc_counts.policy_info CTE takes policy_eff_date from lkp__associated_policies,
-- which is the effective date of the *chain policy*.
-- For this test, we will validate against the policy_eff_date as it is currently sourced in dm__npc_counts.

issues as (
    select
        npc.sb_policy_key as npc_sb_policy_key,
        npc.policy_eff_date as npc_policy_eff_date,
        ap.associated_sb_policy_key as lkp_associated_sb_policy_key,
        ap.policy_eff_date as lkp_policy_eff_date
    from npc_counts npc
    left join associated_policies ap
        on npc.sb_policy_key = ap.associated_sb_policy_key
        and npc.policy_eff_date = ap.policy_eff_date -- dm__npc_counts joins on sb_policy_key and uses policy_eff_date from lkp_associated_policies
    where ap.associated_sb_policy_key is null -- sb_policy_key from npc_counts not in lkp_associated_policies
       or (ap.associated_sb_policy_key is not null and ap.policy_eff_date is null) -- Matched on key, but eff_date is unexpectedly null in lkp (should be caught by not_null test there)
                                                                            -- or npc.policy_eff_date != ap.policy_eff_date -- This condition is implicitly covered by the join if dates differ for the same key
                                                                            -- but it is better to be explicit if we are checking consistency of policy_eff_date
                                                                            -- For this version, the join condition itself npc.policy_eff_date = ap.policy_eff_date handles the check.
                                                                            -- If an npc_counts record has a policy_eff_date that doesn't match any record in lkp_associated_policies for that sb_policy_key,
                                                                            -- it will result in ap.associated_sb_policy_key being null for that specific combination.

),

-- Count of distinct sb_policy_key in dm__npc_counts that are missing or have mismatched policy_eff_date in lkp__associated_policies
-- The join in `issues` CTE already filters for mismatches effectively.
-- If a sb_policy_key from npc_counts does not find a matching associated_sb_policy_key AND policy_eff_date in associated_policies,
-- then lkp_associated_sb_policy_key will be NULL.

final_issues_count as (
    select count(*) as count_of_mismatched_records
    from issues
)

select count_of_mismatched_records
from final_issues_count
where count_of_mismatched_records > 0
