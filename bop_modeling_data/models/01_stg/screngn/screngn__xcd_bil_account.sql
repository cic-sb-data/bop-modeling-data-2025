-- depends_on: {{ ref('xcd_bil_acct_key') }}

with

{{ with_ref('raw__screngn__xcd_bil_account', 'raw') }},

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

        * exclude (
            bil_account_id_hash,
            BIL_ACCOUNT_ID,
            BIL_CLASS_CD,
            BAT_PAY_CLT_ID,
            BIL_SUS_FU_REA_CD,
            BAT_CASH_STATUS_CD,
            BIL_SUS_DSB_REA_CD,
            APP_MIGRATION_CD,
            BIL_TYPE_CD,
            BIL_TYPE_DESC,
            BAT_STATUS_CD,
            BAT_STATUS_DESC,
            BIL_PRESENTMENT_CD,
            BIL_PRESENTMENT_DESC,
            BIL_COLLECTION_MTH,
            BIL_COLLECTION_METHOD_DESC,
            BIL_COLLECTION_PLN,
            BIL_COLLECTION_PLN_DESC,
            BIL_ACCOUNT_NBR,
            BAT_PREV_BAL_AMT
        ) replace (
            try_cast(bat_start_due_dt as date) as BAT_START_DUE_DT,
            coalesce(try_cast(bat_last_day_ind as integer), -1) as BAT_LAST_DAY_IND,
            try_cast(BIL_START_RFR_DT as date) as BIL_START_RFR_DT,
            coalesce(try_cast(BIL_RFR_LST_DAY as integer), -1) as BIL_RFR_LST_DAY,

            try_cast(BIL_LOK_TS as datetime) as BIL_LOK_TS,
            try_cast(BIL_START_DED_DT as date) as BIL_START_DED_DT,
            try_cast(BIL_START_DED_RFR_DT as date) as BIL_START_DED_RFR_DT
        ) 
    from raw
),

add_acct_key as ({{ add_bil_acct_key('renamed_casted') }})

select * exclude (billing_acct_id)
from add_acct_key