with

-- IMPORTS
sb_pols as (
    select 
        policy_chain_id,
        sb_policy_key,
        lob

    from {{ ref('lkp__sb_policy_key') }}
),


billing_pols as (
    select 
        associated_policy_key,
        associated_sb_policy_key,
        billing_acct_key,
        billing_policy_key,

        policy_sym as associated_policy_sym,
        policy_numb as associated_policy_numb,
        policy_eff_date as associated_policy_eff_date

    from {{ ref('lkp__billing_policies') }}
),

associated_to_sb_policy as (
    select distinct
        associated_policy_key,
        associated_sb_policy_key

    from billing_pols
),

billing_activity as (
    select  
        activity_trans_key,
        associated_policy_key,
        associated_sb_policy_key,
        billing_activity_date,
        billing_activity_amt

    from {{ ref('fct__billing_activity') }}
),

prior_activity_dates as (   
    select 
        activity_trans_key,
        billing_activity_date,
        policy_eff_date
    from {{ ref('fct__prior_activity_dates') }}
)




