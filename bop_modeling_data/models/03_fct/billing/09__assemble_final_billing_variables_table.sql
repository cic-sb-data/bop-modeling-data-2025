-- Assemble the final billing variables table, matching SAS BOP_cincibill output.

with

cutoffs as (
    select *
    from {{ ref('04__join_policy_keys_to_policy_chains_and_calculate_date_cutoffs') }}
),

npc_counts as (
    select *
    from {{ ref('08__calculate_non_pay_cancel_counts_by_year') }}
)

select
    c.sb_aiv_key as policy_image_key,
    c.image_eff_date,
    c.image_exp_date,
    c.policy_chain_id,
    c.company_numb,
    c.policy_sym,
    c.policy_numb,
    c.policy_module,
    c.policy_eff_date,
    c.bil_eval_date,
    n.NonPayCancel_Count_prev_1 as npc_prev1,
    n.NonPayCancel_Count_prev_2 as npc_prev2,
    n.NonPayCancel_Count_prev_3 as npc_prev3,
    n.NonPayCancel_Count_prev_4 as npc_prev4,
    n.NonPayCancel_Count_prev_5 as npc_prev5,
    n.NonPayCancel_Count_cprev_2 as npc_cprev2,
    n.NonPayCancel_Count_cprev_3 as npc_cprev3,
    n.NonPayCancel_Count_cprev_4 as npc_cprev4,
    n.NonPayCancel_Count_cprev_5 as npc_cprev5
from cutoffs c
left join npc_counts n
    on c.sb_aiv_key = n.sb_aiv_key
order by c.sb_aiv_key
