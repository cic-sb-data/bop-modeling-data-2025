with

{{ with_ref('fct__associated_policy_eff_date', 'policy_eff_date') }},
{{ with_ref('fct__billing_activity', 'activity') }},

joined as (
    select distinct
        activity.activity_trans_key,
        activity.billing_activity_date,
        policy_eff_date.policy_eff_date

    from activity 
    left join policy_eff_date 
        on activity.associated_policy_key = policy_eff_date.associated_policy_key
    where 
        coalesce(
            policy_eff_date.policy_eff_date,
            {{ mdy(12, 31, 9999) }}
        ) > {{ mdy(12, 31, 9999) }}
),

prior_year_columns as (
    {{ make_n_prior_year_cols('joined') }}
),

filter_out_activity_not_knowable_at_policy_eff_date as (
    select *
    from prior_year_columns
    where policy_eff_date < billing_activity_date
    order by 
        activity_trans_key,
        billing_activity_date
)


select *
from filter_out_activity_not_knowable_at_policy_eff_date