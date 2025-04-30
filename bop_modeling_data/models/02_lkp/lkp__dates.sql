with

input_date as (
    select distinct policy_eff_date as input_date
    from {{ ref('lkp__sb_policy_key') }}
    order by input_date
),

prior_year1 as (
    select
        input_date,
        1 as n_prior_years,
        input_date - interval 1 year as prior_year_start,
        input_date - interval 4 month as prior_year_end

    from input_date
),

prior_year2 as (
    select
        input_date,
        2 as n_prior_years,
        input_date - interval 2 year as prior_year_start,
        input_date - interval 1 year as prior_year_end

    from input_date
),

prior_year3 as (
    select
        input_date,
        3 as n_prior_years,
        input_date - interval 3 year as prior_year_start,
        input_date - interval 2 year as prior_year_end

    from input_date
),

prior_year4 as (
    select
        input_date,
        4 as n_prior_years,
        input_date - interval 4 year as prior_year_start,
        input_date - interval 3 year as prior_year_end

    from input_date
),

prior_year5 as (
    select
        input_date,
        5 as n_prior_years,
        input_date - interval 5 year as prior_year_start,
        input_date - interval 4 year as prior_year_end

    from input_date
),

prior_dates as (
    select * from prior_year1
    union select * from prior_year2
    union select * from prior_year3
    union select * from prior_year4
    union select * from prior_year5
)

select distinct 
    input_date,
    n_prior_years,
    try_cast(prior_year_start as date) as prior_year_start,
    try_cast(prior_year_end as date) as prior_year_end

from prior_dates
order by
    input_date,
    n_prior_years