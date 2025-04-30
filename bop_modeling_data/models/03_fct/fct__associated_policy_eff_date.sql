with

policies as (
    select 
        associated_policy_key,
        policy_eff_date
        
    from {{ ref('lkp__associated_policies') }}
),

dates as (
    select 
        input_date as policy_eff_date,
        n_prior_years,
        prior_year_start,
        prior_year_end

    from {{ ref('lkp__dates') }}
),

eff_date_lkp as (
    select 
        policies.associated_policy_key,
        dates.*

    from policies 
    left join dates
        on policies.policy_eff_date = dates.policy_eff_date
)

select *
from eff_date_lkp