-- depends_on: {{ ref('lkp__bil_acct_key') }}

with

raw as (select * from {{ ref('raw__screngn__xcd_bil_act_summary') }}),
acct_key as (select * from {{ ref('lkp__bil_acct_key') }}),
act_desc_key as (select * from {{ ref('_xcd_act_desc_key') }}),
act_reason_key as (select * from {{ ref('_xcd_act_reason_key') }}),
act_summary_key as (select * from {{ ref('lkp__bil_act_summary_key') }}),

recode_and_renamed as (
    select
        BIL_ACCOUNT_ID as bil_acct_id,
        POL_SYMBOL_CD as policy_sym,
        try_cast(POL_NBR as uinteger) as policy_numb,
        BIL_ACY_DES_CD as bil_act_desc_code,
        BIL_DES_REA_TYP as bil_act_reason_type_code,
        {{ recode__sas_date_format('BIL_ACY_DES1_DT') }} as bil_act_desc1_date,
        {{ recode__sas_date_format('BIL_ACY_DES2_DT') }} as bil_act_desc2_date,
        {{ recode__sas_date_format('BIL_ACY_DT') }} as bil_act_date,
        try_cast(BIL_ACY_AMT as double) as bil_act_amt,
        USER_ID as user_id,
        split(BIL_ACY_TS, ':')[1] as bil_act_time,
        BAS_ADD_DATA_TXT as bil_act_summary_addl_data,

        * exclude (
            bil_account_id,
            bil_acy_des1_dt,
            bil_acy_des2_dt,
            bil_acy_dt,
            pol_symbol_cd,
            pol_nbr,
            bil_account_id_hash
        )

    from raw
),

add_acct_key as (
    select
        

joined as (
    select 
        act_summary_key.bil_act_summary_key,
        acct_key.bil_acct_key,
        act_desc_key.bil_act_desc_key,
        act_reason_key.bil_act_reason_key,
        acct_key.* exclude (bil_acct_key)
        
    from add_acct_key as acct_key
    left join act_summary_key
        on acct_key.bil_acct_id = acct_key.bil_acct_id
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
from recode_and_renamed
