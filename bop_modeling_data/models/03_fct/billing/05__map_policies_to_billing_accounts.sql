-- This model maps policies to billing accounts, following the SAS logic for pol_s2n_acct and all_bil_acct_for_s2n.

with

policy_cutoffs as (
    select *
    from {{ ref('04__join_policy_keys_to_policy_chains_and_calculate_date_cutoffs') }}
),

chains as (
    select 
        sb_policy_key,
        policy_chain_id

    from {{ ref('stg__decfile__sb_policy_lookup') }}
)

billing_policy as (
    select
        bil_account_id,
        bil_account_nbr,
        pol_symbol as policy_sym,
        try_cast(policy_numb as bigint) as pol_nbr_numb,
        policy_numb as pol_nbr
    from {{ ref('stg__screngn__xcd_bil_policy') }}
),

-- Step 1: Map policy symbol/number to billing account
pol_s2n_acct as (
    select distinct
        bil_account_id,
        bil_account_nbr,
        left(pol_symbol_2, 2) as pol_symbol_2,
        pol_nbr_numb,
        pol_nbr
    from billing_policy
),

-- Step 2: Add chain id by lookup
chain_lookup as (
    select
        p.*,
        c.policy_chain_id
    from pol_s2n_acct p
    left join {{ ref('stg__modcom__policy_chain_v3') }} c
        on p.pol_symbol_2 = c.policy_sym
        and p.pol_nbr_numb = c.policy_numb
),

-- Step 3: Get all billing accounts for all policies in the chain
all_bil_acct_for_s2n as (
    select distinct
        c2.policy_sym as policy_sym_2,
        c2.policy_numb,
        c1.bil_account_id,
        c1.bil_account_nbr,
        c1.policy_chain_id
    from chain_lookup c1
    left join {{ ref('stg__modcom__policy_chain_v3') }} c2
        on c1.policy_chain_id = c2.policy_chain_id
)

select *
from all_bil_acct_for_s2n
