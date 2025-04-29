with

raw as (
    select 
        bil_account_id,
        bil_account_id_hash,
        * exclude(
            bil_account_id,
            bil_account_id_hash
        ) replace (
            {{ recode__sas_date_format('POL_EFFECTIVE_DT') }} as POL_EFFECTIVE_DT,
            {{ recode__sas_date_format('BIL_INV_DT') }} as BIL_INV_DT,
            {{ recode__sas_date_format('BIL_ADJ_DUE_DT') }} as BIL_ADJ_DUE_DT,
            {{ recode__sas_date_format('BIL_REFERENCE_DT') }} as BIL_REFERENCE_DT,
        ) 

    from read_csv_auto('{{ var("raw_csv_loc") }}/screngn__xcd_bil_ist_schedule.csv')
)

select *
from raw