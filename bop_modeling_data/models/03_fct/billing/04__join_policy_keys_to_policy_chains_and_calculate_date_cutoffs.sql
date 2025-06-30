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
        {{ five_key(table='images') }},
        chains.policy_chain_id,

        -- Claims evaluation and cutoff dates (SAS intnx logic)
        {# dateadd(month, -4, images.image_eff_date) as clm_eval_date, #}
        {{ date_add('month', -4, 'images.image_eff_date') }} as clm_eval_date,

        {{ date_add('month', -8, date_add('month', -4, images.image_eff_date)) }} as clm_prev_1yr_start,
        {{ date_add('month', -20, date_add('month', -4, images.image_eff_date)) }} as clm_prev_2yr_start,
        {{ date_add('month', -32, date_add('month', -4, images.image_eff_date)) }} as clm_prev_3yr_start,
        {{ date_add('month', -44, date_add('month', -4, images.image_eff_date)) }} as clm_prev_4yr_start,
        {{ date_add('month', -56, date_add('month', -4, images.image_eff_date)) }} as clm_prev_5yr_start,

        {{ date_add('month', -4, images.image_eff_date) }} as clm_prev_1yr_end,
        {{ date_add('month', -8, date_add('month', -4, images.image_eff_date)) }} as clm_prev_2yr_end,
        {{ date_add('month', -20, date_add('month', -4, images.image_eff_date)) }} as clm_prev_3yr_end,
        {{ date_add('month', -32, date_add('month', -4, images.image_eff_date)) }} as clm_prev_4yr_end,
        {{ date_add('month', -44, date_add('month', -4, images.image_eff_date)) }} as clm_prev_5yr_end,

        -- Billing evaluation and cutoff dates (SAS intnx logic)
        {{ date_add('month', -4, images.image_eff_date) }} as bil_eval_date,

        {{ date_add('year', -1, images.image_eff_date) }} as bil_prev_1yr_start,
        {{ date_add('year', -2, images.image_eff_date) }} as bil_prev_2yr_start,
        {{ date_add('year', -3, images.image_eff_date) }} as bil_prev_3yr_start,
        {{ date_add('year', -4, images.image_eff_date) }} as bil_prev_4yr_start,
        {{ date_add('year', -5, images.image_eff_date) }} as bil_prev_5yr_start,

        {{ date_add('month', -4, images.image_eff_date) }} as bil_prev_1yr_end,
        {{ date_add('year', -1, images.image_eff_date) }}  as bil_prev_2yr_end,
        {{ date_add('year', -2, images.image_eff_date) }}  as bil_prev_3yr_end,
        {{ date_add('year', -3, images.image_eff_date) }}  as bil_prev_4yr_end,
        {{ date_add('year', -4, images.image_eff_date) }}  as bil_prev_5yr_end

    from deduped
    left join images
        on deduped.sb_aiv_key = images.sb_aiv_key
    left join chains
        on {{ five_key_join(table1='deduped', table2='chains') }}
)

select * from joined