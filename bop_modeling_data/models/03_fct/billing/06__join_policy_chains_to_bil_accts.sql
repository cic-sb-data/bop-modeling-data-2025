-- Join policy chains to billing accounts and add existence indicator (cinbill_acct_by_chain_exists_ind).

with

cutoffs as (
    select *
    from {{ ref('04__join_policy_keys_to_policy_chains_and_calculate_date_cutoffs') }}
),

bil_accts as (
    select *
    from {{ ref('05__map_policies_to_bil_accts') }}
),

joined as (
    select
        c.sb_aiv_key,
        c.sb_policy_key,
        c.company_numb,
        c.policy_sym,
        c.policy_numb,
        c.policy_module,
        c.policy_eff_date,
        c.image_eff_date,
        c.image_exp_date,
        c.policy_chain_id,
        c.clm_eval_date,
        c.clm_prev_1yr_start,
        c.clm_prev_2yr_start,
        c.clm_prev_3yr_start,
        c.clm_prev_4yr_start,
        c.clm_prev_5yr_start,
        c.clm_prev_1yr_end,
        c.clm_prev_2yr_end,
        c.clm_prev_3yr_end,
        c.clm_prev_4yr_end,
        c.clm_prev_5yr_end,
        c.bil_eval_date,
        c.bil_prev_1yr_start,
        c.bil_prev_2yr_start,
        c.bil_prev_3yr_start,
        c.bil_prev_4yr_start,
        c.bil_prev_5yr_start,
        c.bil_prev_1yr_end,
        c.bil_prev_2yr_end,
        c.bil_prev_3yr_end,
        c.bil_prev_4yr_end,
        c.bil_prev_5yr_end,
        b.bil_account_id,
        b.bil_account_nbr,
        -- Existence indicator: 1 if any billing account exists for the chain, else 0
        max(case when b.bil_account_id is not null then 1 else 0 end) over (partition by c.sb_aiv_key) as cinbill_acct_by_chain_exists_ind
    from cutoffs c
    left join bil_accts b
        on c.policy_chain_id = b.policy_chain_id
)

select *
from joined
