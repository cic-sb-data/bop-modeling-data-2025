-- Calculate non-pay cancel counts for each window and cumulative, matching SAS rnpc_count_prev_2 logic.

with

date_cutoffs as (
    select 
        bil_acct_key,
        sb_policy_key,
        policy_eff_date,
        policy_chain_id,
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
        bil_prev_5yr_end,
        cinbill_acct_by_chain_exists_ind

    from {{ ref('06__join_policy_chains_to_bil_accts') }}
),

activity_dates as (
    select distinct
        bil_act_summary_key,
        bil_act_date

    from {{ ref('lkp__bil_act_summary_key') }}
),

npc_amounts as (
    select 
        step7.bil_act_summary_key,
        step7.bil_acct_key,
        dates.bil_act_date,
        step7.bil_act_amt

    from {{ ref('07__extract_non_pay_cancellation_transactions') }} as step7
    left join activity_dates as dates
        on step7.bil_act_summary_key = dates.bil_act_summary_key
),

joined as (
    select
        cutoffs.bil_acct_key,
        cutoffs.sb_policy_key,
        cutoffs.policy_eff_date,
        cutoffs.policy_chain_id,
        cutoffs.bil_eval_date,
        
        case 
            when cutoffs.bil_prev_1yr_start <= npc_amounts.bil_act_date 
                and npc_amounts.bil_act_date < cutoffs.bil_prev_1yr_end 
                then 1 
            when cutoffs.bil_prev_2yr_start <= npc_amounts.bil_act_date 
                and npc_amounts.bil_act_date < cutoffs.bil_prev_2yr_end 
                then 2 
            when cutoffs.bil_prev_3yr_start <= npc_amounts.bil_act_date 
                and npc_amounts.bil_act_date < cutoffs.bil_prev_3yr_end 
                then 3 
            when cutoffs.bil_prev_4yr_start <= npc_amounts.bil_act_date 
                and npc_amounts.bil_act_date < cutoffs.bil_prev_4yr_end 
                then 4 
            when cutoffs.bil_prev_5yr_start <= npc_amounts.bil_act_date 
                and npc_amounts.bil_act_date < cutoffs.bil_prev_5yr_end 
                then 5 
            else null
        end as bil_act_date_window,
        cutoffs.cinbill_acct_by_chain_exists_ind

    from date_cutoffs as cutoffs
    left join npc_amounts as r
        on c.bil_acct_key = r.bil_acct_key
)

, agg as (
    select
        sb_policy_key,
        policy_chain_id,
        cinbill_acct_by_chain_exists_ind,
        bil_eval_date,
        -- Windowed counts
        sum(case when bil_prev_1yr_start <= bil_act_date and bil_act_date < bil_prev_1yr_end then 1 else 0 end) 
            * case when cinbill_acct_by_chain_exists_ind = 0 then null else 1 end as NonPayCancel_Count_prev_1,
        sum(case when bil_prev_2yr_start <= bil_act_date and bil_act_date < bil_prev_2yr_end then 1 else 0 end) 
            * case when cinbill_acct_by_chain_exists_ind = 0 then null else 1 end as NonPayCancel_Count_prev_2,
        sum(case when bil_prev_3yr_start <= bil_act_date and bil_act_date < bil_prev_3yr_end then 1 else 0 end) 
            * case when cinbill_acct_by_chain_exists_ind = 0 then null else 1 end as NonPayCancel_Count_prev_3,
        sum(case when bil_prev_4yr_start <= bil_act_date and bil_act_date < bil_prev_4yr_end then 1 else 0 end) 
            * case when cinbill_acct_by_chain_exists_ind = 0 then null else 1 end as NonPayCancel_Count_prev_4,
        sum(case when bil_prev_5yr_start <= bil_act_date and bil_act_date < bil_prev_5yr_end then 1 else 0 end) 
            * case when cinbill_acct_by_chain_exists_ind = 0 then null else 1 end as NonPayCancel_Count_prev_5
    from joined
    group by
        sb_policy_key,
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
from joined
