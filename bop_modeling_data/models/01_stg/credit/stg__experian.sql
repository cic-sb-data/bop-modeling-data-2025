-- Note that in this model variable definitions are abstracted to macros.
-- See the macros/variable_definitions directory for the details of the variables used in this model.

with

experian as (select * from {{ ref('raw__experian__co_polterms_exper_vars_all_hits') }}),
pols as (select * from {{ ref('lkp__associated_policies') }})

add_associated_policy_key as (
    select
        pols.associated_policy_key,
        experian.* exclude (
            company_numb,
            policy_sym,
            policy_numb,
            policy_module,
            policy_eff_date,
        )

    from pols
    left join experian 
        on pols.company_numb = experian.company_numb
        and pols.policy_sym = experian.policy_sym
        and pols.policy_numb = experian.policy_numb
        and pols.policy_module = experian.policy_module
        and pols.policy_eff_date = experian.policy_eff_date
),

rename_and_recode as (
    select
        associated_policy_key,
        try_cast(date_of_data_dt as date) as date_of_data_dt,
        bin as experian_bin,
        commercial_intelliscore as  commercial_intelliscore,
        try_cast(yearsinfile as integer) as yearsinfile,
        try_cast(alltrades as double) as alltrades,
        try_cast(baltot as double) as baltot,
        try_cast(ballate_all_dbt as double) as ballate_all_dbt,
        try_cast(numtot_combined as double) as numtot_combined,
        try_cast(baltot_combined as double) as baltot_combined,
        try_cast(judgmentcount as integer) as judgmentcount,
        try_cast(liencount as integer) as liencount,
        try_cast(bkc006 as integer) as bankruptcy_cnt,
        try_cast(ttc038 as double) as ttc038,
        try_cast(ttc039 as double) as ttc039,
        * exclude (
            associated_policy_key,
            date_of_data_dt,
            bin,
            commercial_intelliscore,
            yearsinfile,
            alltrades,
            baltot,
            ballate_all_dbt,
            numtot_combined,
            baltot_combined,
            judgmentcount,
            liencount,
            bankruptcy_cnt,
            ttc038,
            ttc039
        )

    from add_associated_policy_key
)

select *
from rename_and_recode
