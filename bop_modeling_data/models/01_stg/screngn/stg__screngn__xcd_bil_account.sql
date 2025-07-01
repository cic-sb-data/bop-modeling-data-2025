-- depends_on: {{ ref('xcd_bil_acct_key') }}

with

raw as ( select * from {{ ref('raw__screngn__xcd_bil_account') }} ),



renamed_casted as (
    select 
        BIL_ACCOUNT_ID as billing_acct_id,
        try_cast(BIL_ACCOUNT_NBR as ubigint) as billing_acct_numb,
        BIL_CLASS_CD as billing_class_cd,
        BAT_PAY_CLT_ID as billing_acct_paying_client_id,
        BIL_SUS_FU_REA_CD as billing_suspense_followup_reason_cd,
        try_cast(BIL_ACCOUNT_NBR as ubigint) as billing_acct_numb,
        try_cast(BAT_PREV_BAL_AMT as double) as billing_acct_previous_balance_amt,
        BAT_CASH_STATUS_CD as billing_acct_cash_status_cd,
        BIL_SUS_DSB_REA_CD as billing_suspense_disbursement_reason_cd,
        APP_MIGRATION_CD as app_migration_cd,
        BIL_TYPE_CD as billing_type_cd,
        BIL_TYPE_DESC as billing_type_desc,
        BAT_STATUS_CD as billing_acct_status_cd,
        BAT_STATUS_DESC as billing_acct_status_desc,
        BIL_PRESENTMENT_CD as billing_presentment_cd,
        BIL_PRESENTMENT_DESC as billing_presentment_desc,
        BIL_COLLECTION_MTH as billing_collection_method,
        BIL_COLLECTION_METHOD_DESC as billing_collection_method_desc,
        BIL_COLLECTION_PLN as billing_collection_plan,
        BIL_COLLECTION_PLN_DESC as billing_collection_plan_desc,
        try_cast(bat_start_due_dt as date) as bil_acct_start_due_date,,
        coalesce(try_cast(bat_last_day_ind as integer), -1) as bil_acct_last_day_ind,
        try_cast(BIL_START_RFR_DT as date) as bil_start_rfr_date,
        coalesce(try_cast(BIL_RFR_LST_DAY as integer), -1) as bil_rfr_last_day,

        try_cast(BIL_LOK_TS as datetime) as bil_lok_ts,
        try_cast(BIL_START_DED_DT as date) as bil_start_ded_date,
        try_cast(BIL_START_DED_RFR_DT as date) as bil_start_ded_rfr_date

    from raw
),

add_acct_key as ({{ add_bil_acct_key('renamed_casted') }}),

drop_billing_acct_id as (
    select * exclude (billing_acct_id)
    from add_acct_key
),

sub_categorical_vars as (
    with

    raw as (select * from drop_billing_acct_id),

    billing_suspense_disbursement_reason as (
        select 
            lkp.billing_suspense_disbursement_reason_id,
            raw.* exclude (billing_suspense_disbursement_reason_cd)

        from raw
        left join {{ ref('lkp__bil_sus_disbursement_reason_id') }} as lkp
            on raw.billing_suspense_disbursement_reason_cd = lkp.billing_suspense_disbursement_reason_cd

    ),

    status as (
        select 
            lkp.bil_acct_status_id,
            raw.* exclude (billing_acct_status_cd, billing_acct_status_desc)

        from billing_suspense_disbursement_reason as raw
        left join {{ ref('lkp__bil_acct_status_id') }} as lkp
            on raw.billing_acct_status_cd = lkp.billing_acct_status_cd
    ),

    presentment as (
        select 
            lkp.billing_presentment_id,
            raw.* exclude (billing_presentment_cd, billing_presentment_desc)

        from status as raw
        left join {{ ref('lkp__bil_presentment_id') }} as lkp
            on raw.billing_presentment_cd = lkp.billing_presentment_cd
    ),

    collection_method as (
        select 
            lkp.billing_collection_method_id,
            raw.* exclude (billing_collection_method, billing_collection_method_desc)

        from presentment as raw
        left join {{ ref('lkp__bil_collection_method_id') }} as lkp
            on raw.billing_collection_method = lkp.billing_collection_method
    ),

    collection_plan as (
        select 
            lkp.billing_collection_plan_id,
            raw.* exclude (billing_collection_plan, billing_collection_plan_desc)

        from collection_method as raw
        left join {{ ref('lkp__bil_collection_plan_id') }} as lkp
            on raw.billing_collection_plan = lkp.billing_collection_plan
    )

    select *
    from collection_plan

)

select * 
from add_acct_key