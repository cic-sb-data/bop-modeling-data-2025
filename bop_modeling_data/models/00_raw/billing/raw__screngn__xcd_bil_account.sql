with

raw as (
    select 
        * replace (
            try_cast(bat_start_due_dt as date) as BAT_START_DUE_DT,
            coalesce(try_cast(bat_last_day_ind as integer), -1) as BAT_LAST_DAY_IND,
            try_cast(BIL_START_RFR_DT as date) as BIL_START_RFR_DT,
            coalesce(try_cast(BIL_RFR_LST_DAY as integer), -1) as BIL_RFR_LST_DAY,

            try_cast(BIL_LOK_TS as datetime) as BIL_LOK_TS,
            try_cast(BIL_START_DED_DT as date) as BIL_START_DED_DT,
            try_cast(BIL_START_DED_RFR_DT as date) as BIL_START_DED_RFR_DT
        )

    from read_csv_auto('{{ var("raw_csv_loc") }}/screngn__xcd_bil_account.csv')
)

select *
from raw