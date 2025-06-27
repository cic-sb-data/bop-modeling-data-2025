-- This model goes one step further and builds the policy image keys based on the policy keys extracted from the billing data.

with

policies as (select * from {{ ref('01__extract_distinct_policy_ids') }}),
images as (select * from {{ ref('stg__decfile__sb_aiv_lookup') }}),

join_images as (
    select
        images.sb_aiv_key,
        policies.sb_policy_key,
        policies.policy_chain_id,
        policies.lob,
        images.sb_aiv_key,
        images.location_numb,
        images.class_code,
        policies.policy_eff_date,
        images.image_eff_date

    from images
    left join policies
        on policies.sb_policy_key = images.sb_policy_key
        and policies.lob = images.lob
)

select * from join_images