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
            try_cast(POL_EFFECTIVE_DT as date) as POL_EFFECTIVE_DT,
            try_cast(BIL_ADJ_DUE_DT as date) as BIL_ADJ_DUE_DT,
            try_cast(BIL_INV_DT as date) as BIL_INV_DT,
            try_cast(BIL_DSP_DT as date) as BIL_DSP_DT,

        )

    from read_csv_auto('{{ var("raw_csv_loc") }}/screngn__xcd_bil_cash_dsp.csv')
)

select *
from raw