with

-- Policy effective date <--> associated policy key lookup
dts as (
    select distinct
        associated_policy_key,
        policy_eff_date,

        {{ eval_date('policy_eff_date') }} as eval_date,
        {{ prev_yr_start_1toN('policy_eff_date', N=5) }},
        {{ prev_yr_end_1toN('policy_eff_date', N=5) }}

    from {{ ref('fct__associated_policy_eff_date') }}
),


-- billing activity transaction <---> associated policy key lookup
activity as (
    select distinct
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
        
        dts.* exclude (associated_policy_key)

    from activity 
    left join dts 
        on activity.associated_policy_key = dts.associated_policy_key
    
    where dts.policy_eff_date is not null
        and dts.eval_date < activity.billing_activity_date
)

select *
from joined