with

raw as (
    select
        * replace(
        {{ recode__sas_date_format('BIL_ACY_DT') }} as BIL_ACY_DT,
        {{ recode__sas_date_format('BIL_ACY_DES1_DT') }} as BIL_ACY_DES1_DT,
        {{ recode__sas_date_format('BIL_ACY_DES2_DT') }} as BIL_ACY_DES2_DT
    )

    from {{ ref('raw__screngn__xcd_bil_act_summary') }}
    where {{ npc_event() }}
),

act_desc_key as (select * from {{ ref('_lkp__xcd_act_desc_key') }}),
act_reason_key as (select * from {{ ref('_lkp__xcd_act_reason_key') }}),
act_summary_key as (select * from {{ ref('lkp__xcd_bil_act_summary_key') }}),

recode_and_renamed as (
    select
        BIL_ACCOUNT_ID as billing_account_id,
        try_cast(bil_acy_dt as date) as bil_act_date,
        try_cast(BIL_ACY_SEQ as uinteger) as bil_act_seq_numb,
        POL_SYMBOL_CD as policy_sym,
        try_cast(POL_NBR as uinteger) as policy_numb,
        BIL_ACY_DES_CD as bil_act_desc_code,
        BIL_DES_REA_TYP as bil_act_reason_type_code,
        try_cast(BIL_ACY_DES1_DT as date) as bil_act_desc1_date,
        try_cast(BIL_ACY_DES2_DT as date) as bil_act_desc2_date,
        try_cast(BIL_ACY_AMT as double) as bil_act_amt,
        USER_ID as user_id,
        BIL_ACY_TS as bil_act_at,
        BAS_ADD_DATA_TXT as billing_acct_summary_additional_data

    from raw
),

add_acct_key as ({{ add_bil_account_key('recode_and_renamed') }}),

joined as (
    select 
        act_summary_key.bil_act_summary_key,
        acct_key.bil_account_key,
        act_desc_key.bil_act_desc_key,
        act_reason_key.bil_act_reason_key,
        acct_key.* exclude (bil_account_key)
        
    from add_acct_key as acct_key
    left join act_summary_key
        on acct_key.billing_account_id = acct_key.billing_account_id
    left join act_desc_key
        on acct_key.bil_act_desc_code = act_desc_key.bil_act_desc_code 
    left join act_reason_key 
        on acct_key.bil_act_reason_type_code = act_reason_key.bil_act_reason_type_code
    
),

drop_join_cols as (
    select
        *

    from joined
)

select *
from drop_join_cols
