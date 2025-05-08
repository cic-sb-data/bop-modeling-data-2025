{{config(materialization='table')}}

with

-- SB Policy list
sb as (select * from {{ ref('lkp__sb_policy_key') }}),

-- Date lookup
dates as (
    select  
        input_date as policy_eff_date,
        n_prior_years
    from {{ ref('lkp__dates') }}),

-- Policy Chain-Associated Policy list
pchain as (select * from {{ ref('lkp__associated_policies') }}),

-- Billing policy lookup
billing as (select * from {{ ref('lkp__billing_policies') }}),


target_policies_with_cutoffs AS (
    SELECT DISTINCT
        ap.associated_sb_policy_key AS sb_policy_key,
        ap.policy_eff_date AS policyeffectivedate,
        ap.policy_chain_id,
        ap.companycode,
        ap.policysymbol,
        ap.policynumber,
        ap.statisticalpolicymodulenumber,
        ap.imageexpirationdate,

        -- Date cutoffs based on policyeffectivedate as per current_npc_logic.sas
        -- bil_eval_date: 4 months prior to policyeffectivedate
        DATEADD('month', -4, ap.policy_eff_date) AS bil_eval_date,

        -- NonPayCancel_Count_prev_1 Window:
        -- Start: policyeffectivedate - 1 year
        -- End: policyeffectivedate - 4 months (exclusive, so bil_eval_date)
        DATEADD('year', -1, ap.policy_eff_date) AS bil_prev_1yr_start,
        DATEADD('month', -4, ap.policy_eff_date) AS bil_prev_1yr_end, -- This is bil_eval_date

        -- NonPayCancel_Count_prev_2 Window:
        -- Start: policyeffectivedate - 2 years
        -- End: policyeffectivedate - 1 year (exclusive)
        DATEADD('year', -2, ap.policy_eff_date) AS bil_prev_2yr_start,
        DATEADD('year', -1, ap.policy_eff_date) AS bil_prev_2yr_end,

        -- NonPayCancel_Count_prev_3 Window:
        -- Start: policyeffectivedate - 3 years
        -- End: policyeffectivedate - 2 years (exclusive)
        DATEADD('year', -3, ap.policy_eff_date) AS bil_prev_3yr_start,
        DATEADD('year', -2, ap.policy_eff_date) AS bil_prev_3yr_end,

        -- NonPayCancel_Count_prev_4 Window:
        -- Start: policyeffectivedate - 4 years
        -- End: policyeffectivedate - 3 years (exclusive)
        DATEADD('year', -4, ap.policy_eff_date) AS bil_prev_4yr_start,
        DATEADD('year', -3, ap.policy_eff_date) AS bil_prev_4yr_end,

        -- NonPayCancel_Count_prev_5 Window:
        -- Start: policyeffectivedate - 5 years
        -- End: policyeffectivedate - 4 years (exclusive)
        DATEADD('year', -5, ap.policy_eff_date) AS bil_prev_5yr_start,
        DATEADD('year', -4, ap.policy_eff_date) AS bil_prev_5yr_end

    FROM {{ ref('lkp__associated_policies') }} ap
),

billing_accounts_to_chains AS (
    SELECT DISTINCT
        bp.bil_account_id,
        pc3.policy_chain_id
    FROM {{ ref('stg__screngn__xcd_bil_policy') }} bp
    JOIN {{ ref('stg__modcom__policy_chain_v3') }} pc3
        ON CASE bp.company_code -- Assuming bp.company_code holds 'CID', 'CIC', 'CCC'
               WHEN 'CID' THEN 3
               WHEN 'CIC' THEN 5
               WHEN 'CCC' THEN 7
               ELSE -1 -- Or some other non-matching value
           END = pc3.COMPANY_NUMB
        AND bp.policy_symbol = pc3.POLICY_SYM
        AND TRY_CAST(bp.policy_number AS INTEGER) = pc3.POLICY_NUMB -- Assuming pc3.POLICY_NUMB is INTEGER
        AND bp.term_effective_date_from_billing_record = pc3.POLICY_EFF_DATE -- Assuming bp has this field mapped from source
        AND TRY_CAST(bp.policy_module AS INTEGER) = pc3.POLICY_MODULE -- Assuming pc3.POLICY_MODULE is INTEGER and bp.policy_module needs cast
)

-- Next CTEs to be implemented based on npc-counts.md:
-- policies_linked_to_billing_accounts
-- npc_events_raw
-- policy_npc_event_counts
-- final_npc_counts
-- Final SELECT statement

SELECT *
FROM billing_accounts_to_chains
