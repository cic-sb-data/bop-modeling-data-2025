-- This model serves as a lookup for the billing variables by policy key

with

raw_computed as (
    select *
    from {{ ref('09__assemble_final_billing_variables_table') }}
),

{# If intermediate steps are needed before outputting the final table, do them here: #}
intermediate_steps as (
    select *
    from raw_computed
),

final as (
    select
        sb_policy_key,
        billing_eval_date,
        n_prior_years,
        non_pay_cancel_counts

    from intermediate_steps
)

select * from final