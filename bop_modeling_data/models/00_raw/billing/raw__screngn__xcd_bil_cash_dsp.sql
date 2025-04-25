with

raw as (
    select 
        *

    from read_csv_auto('{{ var("raw_csv_loc") }}/screngn__xcd_bil_cash_dsp.csv')
)

select *
from raw