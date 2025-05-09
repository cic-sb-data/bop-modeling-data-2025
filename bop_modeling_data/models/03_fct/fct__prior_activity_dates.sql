with

-- Policy effective date <--> associated policy key lookup
policy_eff_date as (
    select
        associated_policy_key,
        policy_eff_date

    from {{ ref('fct__associated_policy_eff_date') }}
),

-- billing activity transaction <---> associated policy key lookup
activity as (
    select
        associated_policy_key,
        activity_trans_key,
        billing_activity_date

    from {{ ref('fct__billing_activity') }}
    where
        billing_activity_date < {{ mdy(12, 31, 9999) }}
        and associated_policy_key is not null
),

-- Join activity and policy effective date tables
-- to get the policy effective date corresponding to the 
-- policy behind the billing activity
joined as (
    select distinct
        activity.activity_trans_key,
        activity.billing_activity_date,
        policy_eff_date.policy_eff_date

    from activity 
    left join policy_eff_date 
        on activity.associated_policy_key = policy_eff_date.associated_policy_key
    
    where policy_eff_date.policy_eff_date is not null
        and policy_eff_date.policy_eff_date < activity.billing_activity_date
),

prior_year_columns as (
    {{ make_n_prior_year_cols('joined') }}
)

select *
from prior_year_columns
where prior_year is not null