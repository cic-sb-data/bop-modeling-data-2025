-- This model builds the policy image keys based on the policy keys extracted from the billing data.
-- Follows the logic of the SAS step: join cfxmlid to policy image table for all relevant fields.

with

policies as (
    select * from {{ ref('01__extract_distinct_policy_ids') }}
),
images as (
    select * from {{ ref('stg__decfile__sb_aiv_lookup') }}
),

join_images as (
    select
        images.sb_aiv_key,
        policies.sb_policy_key,
        policies.policy_chain_id,
        policies.lob,
        images.location_numb,
        images.class_code,
        policies.company_numb,
        policies.policy_sym,
        policies.policy_numb,
        policies.policy_module,
        policies.policy_eff_date,
        images.image_eff_date,
        images.image_exp_date
    from images
    left join policies
        on policies.sb_policy_key = images.sb_policy_key
        and policies.lob = images.lob
)

select * from join_images