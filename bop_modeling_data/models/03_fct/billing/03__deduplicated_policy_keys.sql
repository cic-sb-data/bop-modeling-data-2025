-- This model takes the output from the combined and cleaned policy keys and performs a deduplication step

with 

raw as (
    select *
    from {{ ref('02__build_policy_image_keys') }}
),

deduped as (
    select distinct *
    from raw
    where sb_aiv_key is not null
)

select * from deduped