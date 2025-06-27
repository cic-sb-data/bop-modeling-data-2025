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
        d.sb_aiv_key,
        d.sb_policy_key,
        i.company_numb,
        i.policy_sym,
        i.policy_numb,
        i.policy_module,
        i.policy_eff_date,
        i.image_eff_date,
        i.image_exp_date,
        c.policy_chain_id,

        -- Claims evaluation and cutoff dates (SAS intnx logic)
        dateadd(month, -4, i.image_eff_date) as clm_eval_date,

        dateadd(month, -8,  dateadd(month, -4, i.image_eff_date))  as clm_prev_1yr_start,
        dateadd(month, -20, dateadd(month, -4, i.image_eff_date))  as clm_prev_2yr_start,
        dateadd(month, -32, dateadd(month, -4, i.image_eff_date))  as clm_prev_3yr_start,
        dateadd(month, -44, dateadd(month, -4, i.image_eff_date))  as clm_prev_4yr_start,
        dateadd(month, -56, dateadd(month, -4, i.image_eff_date))  as clm_prev_5yr_start,

        dateadd(month, -4, i.image_eff_date)                      as clm_prev_1yr_end,
        dateadd(month, -8,  dateadd(month, -4, i.image_eff_date)) as clm_prev_2yr_end,
        dateadd(month, -20, dateadd(month, -4, i.image_eff_date)) as clm_prev_3yr_end,
        dateadd(month, -32, dateadd(month, -4, i.image_eff_date)) as clm_prev_4yr_end,
        dateadd(month, -44, dateadd(month, -4, i.image_eff_date)) as clm_prev_5yr_end,

        -- Billing evaluation and cutoff dates (SAS intnx logic)
        dateadd(month, -4, i.image_eff_date) as bil_eval_date,

        dateadd(year, -1, i.image_eff_date) as bil_prev_1yr_start,
        dateadd(year, -2, i.image_eff_date) as bil_prev_2yr_start,
        dateadd(year, -3, i.image_eff_date) as bil_prev_3yr_start,
        dateadd(year, -4, i.image_eff_date) as bil_prev_4yr_start,
        dateadd(year, -5, i.image_eff_date) as bil_prev_5yr_start,

        dateadd(month, -4, i.image_eff_date) as bil_prev_1yr_end,
        dateadd(year, -1, i.image_eff_date)  as bil_prev_2yr_end,
        dateadd(year, -2, i.image_eff_date)  as bil_prev_3yr_end,
        dateadd(year, -3, i.image_eff_date)  as bil_prev_4yr_end,
        dateadd(year, -4, i.image_eff_date)  as bil_prev_5yr_end

    from deduped d
    left join images i
        on d.sb_aiv_key = i.sb_aiv_key
    left join chains c
        on i.company_numb = c.company_numb
        and i.policy_sym = c.policy_sym
        and i.policy_numb = c.policy_numb
        and i.policy_module = c.policy_module
        and i.policy_eff_date = c.policy_eff_date
)

select * from joined