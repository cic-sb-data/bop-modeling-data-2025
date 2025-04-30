with

raw as (
    select * replace(
        {{ recode__sas_date_format('BIL_ACY_DT') }} as BIL_ACY_DT,
        {{ recode__sas_date_format('BIL_ACY_DES1_DT') }} as BIL_ACY_DES1_DT,
        {{ recode__sas_date_format('BIL_ACY_DES2_DT') }} as BIL_ACY_DES2_DT
    )

    from read_csv_auto('{{ var("raw_csv_loc") }}/screngn__xcd_bil_act_summary.csv')
)

select *
from raw