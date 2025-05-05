WITH billing_activity AS (
    SELECT
        sb_policy_key,
        billing_activity_date,
        billing_activity_amount
    FROM {{ ref('fct__billing_activity') }}
),

policy_info AS (
    -- Using lkp__associated_policies as the base for policies and their effective dates
    SELECT DISTINCT
        sb_policy_key,
        policy_chain_id,
        policy_eff_date
    FROM {{ ref('lkp__associated_policies') }}
),

-- Calculate nth_prior_year relative to policy_eff_date
-- Join activities with policy info to get the reference date
prior_year_activities AS (
    SELECT
        p.sb_policy_key,
        p.policy_eff_date,
        b.billing_activity_date,
        b.billing_activity_amount,
        -- Determine nth prior year (only for activities *before* the policy eff date)
        CASE
            WHEN b.billing_activity_date < p.policy_eff_date
            THEN DATE_PART('year', p.policy_eff_date) - DATE_PART('year', b.billing_activity_date)
            ELSE NULL -- Exclude activities on or after the policy eff date for prior year calcs
        END AS nth_prior_year
    FROM policy_info p
    JOIN billing_activity b
      ON p.sb_policy_key = b.sb_policy_key
    WHERE
        b.billing_activity_date < p.policy_eff_date -- Only consider activities before the policy effective date
        AND DATE_PART('year', p.policy_eff_date) - DATE_PART('year', b.billing_activity_date) BETWEEN 1 AND 5 -- Limit to 5 prior years as per checklist columns
),

-- Step 7: Aggregate counts and amounts per policy per prior year
aggregated_prior_c_by_year AS (
    SELECT
        sb_policy_key,
        nth_prior_year,
        COUNT(*) AS c_activity_count,
        SUM(billing_activity_amount) AS c_activity_amount_sum
    FROM prior_year_activities
    WHERE nth_prior_year IS NOT NULL -- Filter out any rows where nth_prior_year couldn't be calculated
    GROUP BY
        sb_policy_key,
        nth_prior_year
),

-- Step 8: Final Select - Pivot the aggregated results
final AS (
    SELECT
        p.sb_policy_key,
        p.policy_chain_id,
        p.policy_eff_date,
        -- Pivot using conditional aggregation and coalesce to default to 0
        COALESCE(SUM(CASE WHEN agg.nth_prior_year = 1 THEN agg.c_activity_count ELSE 0 END), 0) AS prior_yr1_c_activity_count,
        COALESCE(SUM(CASE WHEN agg.nth_prior_year = 1 THEN agg.c_activity_amount_sum ELSE 0 END), 0) AS prior_yr1_c_activity_amount_sum,
        COALESCE(SUM(CASE WHEN agg.nth_prior_year = 2 THEN agg.c_activity_count ELSE 0 END), 0) AS prior_yr2_c_activity_count,
        COALESCE(SUM(CASE WHEN agg.nth_prior_year = 2 THEN agg.c_activity_amount_sum ELSE 0 END), 0) AS prior_yr2_c_activity_amount_sum,
        COALESCE(SUM(CASE WHEN agg.nth_prior_year = 3 THEN agg.c_activity_count ELSE 0 END), 0) AS prior_yr3_c_activity_count,
        COALESCE(SUM(CASE WHEN agg.nth_prior_year = 3 THEN agg.c_activity_amount_sum ELSE 0 END), 0) AS prior_yr3_c_activity_amount_sum,
        COALESCE(SUM(CASE WHEN agg.nth_prior_year = 4 THEN agg.c_activity_count ELSE 0 END), 0) AS prior_yr4_c_activity_count,
        COALESCE(SUM(CASE WHEN agg.nth_prior_year = 4 THEN agg.c_activity_amount_sum ELSE 0 END), 0) AS prior_yr4_c_activity_amount_sum,
        COALESCE(SUM(CASE WHEN agg.nth_prior_year = 5 THEN agg.c_activity_count ELSE 0 END), 0) AS prior_yr5_c_activity_count,
        COALESCE(SUM(CASE WHEN agg.nth_prior_year = 5 THEN agg.c_activity_amount_sum ELSE 0 END), 0) AS prior_yr5_c_activity_amount_sum
    FROM policy_info p -- Use policy_info as the base to ensure all policies are included
    LEFT JOIN aggregated_prior_c_by_year agg
      ON p.sb_policy_key = agg.sb_policy_key
    GROUP BY
        p.sb_policy_key,
        p.policy_chain_id,
        p.policy_eff_date
)

SELECT * FROM final
