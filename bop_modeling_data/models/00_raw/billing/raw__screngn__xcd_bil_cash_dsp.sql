with

raw as (
    select 
        bil_account_id,
        bil_account_id_hash,
        * exclude(
            bil_account_id,
            bil_account_id_hash
        ) replace (
            try_cast(bil_dtb_dt as date) as BIL_DTB_DT,
            try_cast(POL_NBR as ubigint) as POL_NBR,
            {{ recode__sas_date_format('POL_EFFECTIVE_DT') }} as POL_EFFECTIVE_DT,
            {{ recode__sas_date_format('BIL_ADJ_DUE_DT') }} as BIL_ADJ_DUE_DT,
            {{ recode__sas_date_format('BIL_INV_DT') }} as BIL_INV_DT,
            {{ recode__sas_date_format('BIL_DSP_DT') }} as BIL_DSP_DT
        )

    from read_csv_auto('{{ var("raw_csv_loc") }}/screngn__xcd_bil_cash_dsp.csv')
)

select *
from raw