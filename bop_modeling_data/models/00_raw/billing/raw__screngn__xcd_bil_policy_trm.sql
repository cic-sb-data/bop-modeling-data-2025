with

raw as (
    select 
        bil_account_id,
        bil_account_id_hash,
        * exclude(
            bil_account_id,
            bil_account_id_hash
        ) replace(
            {{ recode__sas_date_format('POL_EFFECTIVE_DT') }} as POL_EFFECTIVE_DT,
            {{ recode__sas_date_format('PLN_EXP_DT') }} as PLN_EXP_DT,
            {{ recode__sas_date_format('BPT_STATUS_EFF_DT') }} as BPT_STATUS_EFF_DT,
            {{ recode__sas_date_format('BPT_UW_STA_EFF_DT') }} as BPT_UW_STA_EFF_DT
        ) 

    from read_csv_auto('{{ var("raw_csv_loc") }}/screngn__xcd_bil_policy_trm.csv')
)

select *
from raw