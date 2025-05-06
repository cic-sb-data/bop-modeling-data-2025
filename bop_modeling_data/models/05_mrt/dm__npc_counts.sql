{{config(materialization='table')}}

with billing_activity as (
    select
        sb_policy_key,
        billing_activity_date,
        billing_activity_amt as billing_activity_amount
    from {{ ref('fct__billing_activity') }}
),

policy_info as (
    -- Using lkp__associated_policies as the base for policies and their effective dates
    select distinct
        associated_sb_policy_key as sb_policy_key,
        policy_chain_id,
        policy_eff_date
    from {{ ref('lkp__associated_policies') }}
),

-- Calculate nth_prior_year relative to policy_eff_date
-- Join activities with policy info to get the reference date
prior_year_activities as (
    select
        p.sb_policy_key,
        p.policy_eff_date,
        b.billing_activity_date,
        b.billing_activity_amount,
        -- Determine nth prior year (only for activities *before* the policy eff date)
        case
            when b.billing_activity_date < p.policy_eff_date
                then date_part('year', p.policy_eff_date) - date_part('year', b.billing_activity_date)
            else null -- Exclude activities on or after the policy eff date for prior year calcs
        end as nth_prior_year
    from policy_info p
    join billing_activity b
      on p.sb_policy_key = b.sb_policy_key
    where
        b.billing_activity_date < p.policy_eff_date -- Only consider activities before the policy effective date
        and date_part('year', p.policy_eff_date) - date_part('year', b.billing_activity_date) between 1 and 5 -- Limit to 5 prior years as per checklist columns
),

-- Step 7: Aggregate counts and amounts per policy per prior year
aggregated_prior_c_by_year as (
    select
        sb_policy_key,
        nth_prior_year,
        COUNT(*) as c_activity_count,
        sum(billing_activity_amount) as c_activity_amount_sum
    from prior_year_activities
    where nth_prior_year IS NOT null -- Filter out any rows where nth_prior_year couldn't be calculated
    group by
        sb_policy_key,
        nth_prior_year
),

-- Step 8: Final Select - Pivot the aggregated results
final as (
    select
        p.sb_policy_key,
        p.policy_chain_id,
        p.policy_eff_date,
        -- Pivot using conditional aggregation and coalesce to default to 0
        coalesce(sum(case when agg.nth_prior_year = 1 then agg.c_activity_count else 0 end), 0) as prior_yr1_c_activity_count,
        coalesce(sum(case when agg.nth_prior_year = 1 then agg.c_activity_amount_sum else 0 end), 0) as prior_yr1_c_activity_amount_sum,
        coalesce(sum(case when agg.nth_prior_year = 2 then agg.c_activity_count else 0 end), 0) as prior_yr2_c_activity_count,
        coalesce(sum(case when agg.nth_prior_year = 2 then agg.c_activity_amount_sum else 0 end), 0) as prior_yr2_c_activity_amount_sum,
        coalesce(sum(case when agg.nth_prior_year = 3 then agg.c_activity_count else 0 end), 0) as prior_yr3_c_activity_count,
        coalesce(sum(case when agg.nth_prior_year = 3 then agg.c_activity_amount_sum else 0 end), 0) as prior_yr3_c_activity_amount_sum,
        coalesce(sum(case when agg.nth_prior_year = 4 then agg.c_activity_count else 0 end), 0) as prior_yr4_c_activity_count,
        coalesce(sum(case when agg.nth_prior_year = 4 then agg.c_activity_amount_sum else 0 end), 0) as prior_yr4_c_activity_amount_sum,
        coalesce(sum(case when agg.nth_prior_year = 5 then agg.c_activity_count else 0 end), 0) as prior_yr5_c_activity_count,
        coalesce(sum(case when agg.nth_prior_year = 5 then agg.c_activity_amount_sum else 0 end), 0) as prior_yr5_c_activity_amount_sum
    from policy_info p -- Use policy_info as the base to ensure all policies are included
    left join aggregated_prior_c_by_year agg
      on p.sb_policy_key = agg.sb_policy_key
    group by
        p.sb_policy_key,
        p.policy_chain_id,
        p.policy_eff_date
)

select * from final
