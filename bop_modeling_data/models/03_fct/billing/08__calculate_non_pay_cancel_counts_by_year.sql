-- Calculate non-pay cancel counts for each window and cumulative, matching SAS rnpc_count_prev_2 logic.

with

cutoffs as (
    select *
    from {{ ref('06__join_policy_chains_to_billing_accounts') }}
),

rnpc_all as (
    select *
    from {{ ref('07__extract_non_pay_cancellation_transactions') }}
),

joined as (
    select
        c.sb_aiv_key,
        c.policy_chain_id,
        c.cinbill_acct_by_chain_exists_ind,
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
        r.bil_account_id,
        r.bil_acy_dt
    from cutoffs c
    left join rnpc_all r
        on c.bil_account_id = r.bil_account_id
)

, agg as (
    select
        sb_aiv_key,
        policy_chain_id,
        cinbill_acct_by_chain_exists_ind,
        bil_eval_date,
        -- Windowed counts
        sum(case when bil_prev_1yr_start <= bil_acy_dt and bil_acy_dt < bil_prev_1yr_end then 1 else 0 end) 
            * case when cinbill_acct_by_chain_exists_ind = 0 then null else 1 end as NonPayCancel_Count_prev_1,
        sum(case when bil_prev_2yr_start <= bil_acy_dt and bil_acy_dt < bil_prev_2yr_end then 1 else 0 end) 
            * case when cinbill_acct_by_chain_exists_ind = 0 then null else 1 end as NonPayCancel_Count_prev_2,
        sum(case when bil_prev_3yr_start <= bil_acy_dt and bil_acy_dt < bil_prev_3yr_end then 1 else 0 end) 
            * case when cinbill_acct_by_chain_exists_ind = 0 then null else 1 end as NonPayCancel_Count_prev_3,
        sum(case when bil_prev_4yr_start <= bil_acy_dt and bil_acy_dt < bil_prev_4yr_end then 1 else 0 end) 
            * case when cinbill_acct_by_chain_exists_ind = 0 then null else 1 end as NonPayCancel_Count_prev_4,
        sum(case when bil_prev_5yr_start <= bil_acy_dt and bil_acy_dt < bil_prev_5yr_end then 1 else 0 end) 
            * case when cinbill_acct_by_chain_exists_ind = 0 then null else 1 end as NonPayCancel_Count_prev_5
    from joined
    group by
        sb_aiv_key,
        policy_chain_id,
        cinbill_acct_by_chain_exists_ind,
        bil_eval_date,
        bil_prev_1yr_start,
        bil_prev_2yr_start,
        bil_prev_3yr_start,
        bil_prev_4yr_start,
        bil_prev_5yr_start,
        bil_prev_1yr_end,
        bil_prev_2yr_end,
        bil_prev_3yr_end,
        bil_prev_4yr_end,
        bil_prev_5yr_end
)

, cumulative as (
    select
        *,
        NonPayCancel_Count_prev_1 + NonPayCancel_Count_prev_2 as NonPayCancel_Count_cprev_2,
        NonPayCancel_Count_prev_1 + NonPayCancel_Count_prev_2 + NonPayCancel_Count_prev_3 as NonPayCancel_Count_cprev_3,
        NonPayCancel_Count_prev_1 + NonPayCancel_Count_prev_2 + NonPayCancel_Count_prev_3 + NonPayCancel_Count_prev_4 as NonPayCancel_Count_cprev_4,
        NonPayCancel_Count_prev_1 + NonPayCancel_Count_prev_2 + NonPayCancel_Count_prev_3 + NonPayCancel_Count_prev_4 + NonPayCancel_Count_prev_5 as NonPayCancel_Count_cprev_5
    from agg
)

select *
from cumulative
