-- This model joins policy keys to policy chains and calculates date cutoffs.

with

deduped as (
    select *
    from {{ ref('03__deduplicated_policy_keys') }}
),

images as (
    select *
    from {{ ref('02__build_policy_image_keys') }}
),

chains as (
    select *
    from {{ ref('stg__modcom__policy_chain_v3') }}
),

joined as (
    select
        deduped.sb_aiv_key,
        deduped.sb_policy_key,
        images.company_numb,
        images.policy_sym,
        images.policy_numb,
        images.policy_module,
        images.policy_eff_date,
        images.image_eff_date,
        chains.policy_chain_id,

        -- Claims evaluation and cutoff dates (SAS intnx logic)
        dateadd(month, -4, images.image_eff_date) as clm_eval_date,

        dateadd(month, -8,  dateadd(month, -4, images.image_eff_date))  as clm_prev_1yr_start,
        dateadd(month, -20, dateadd(month, -4, images.image_eff_date))  as clm_prev_2yr_start,
        dateadd(month, -32, dateadd(month, -4, images.image_eff_date))  as clm_prev_3yr_start,
        dateadd(month, -44, dateadd(month, -4, images.image_eff_date))  as clm_prev_4yr_start,
        dateadd(month, -56, dateadd(month, -4, images.image_eff_date))  as clm_prev_5yr_start,

        dateadd(month, -4, images.image_eff_date)                      as clm_prev_1yr_end,
        dateadd(month, -8,  dateadd(month, -4, images.image_eff_date)) as clm_prev_2yr_end,
        dateadd(month, -20, dateadd(month, -4, images.image_eff_date)) as clm_prev_3yr_end,
        dateadd(month, -32, dateadd(month, -4, images.image_eff_date)) as clm_prev_4yr_end,
        dateadd(month, -44, dateadd(month, -4, images.image_eff_date)) as clm_prev_5yr_end,

        -- Billing evaluation and cutoff dates (SAS intnx logic)
        dateadd(month, -4, images.image_eff_date) as bil_eval_date,

        dateadd(year, -1, images.image_eff_date) as bil_prev_1yr_start,
        dateadd(year, -2, images.image_eff_date) as bil_prev_2yr_start,
        dateadd(year, -3, images.image_eff_date) as bil_prev_3yr_start,
        dateadd(year, -4, images.image_eff_date) as bil_prev_4yr_start,
        dateadd(year, -5, images.image_eff_date) as bil_prev_5yr_start,

        dateadd(month, -4, images.image_eff_date) as bil_prev_1yr_end,
        dateadd(year, -1, images.image_eff_date)  as bil_prev_2yr_end,
        dateadd(year, -2, images.image_eff_date)  as bil_prev_3yr_end,
        dateadd(year, -3, images.image_eff_date)  as bil_prev_4yr_end,
        dateadd(year, -4, images.image_eff_date)  as bil_prev_5yr_end

    from deduped
    left join images
        on deduped.sb_aiv_key = images.sb_aiv_key
    left join chains
        on images.company_numb = chains.company_numb
        and images.policy_sym = chains.policy_sym
        and images.policy_numb = chains.policy_numb
        and images.policy_module = chains.policy_module
        and images.policy_eff_date = chains.policy_eff_date
)

select * from joined