with

raw as (
    select *
    from read_csv_auto('{{ var("raw_csv_loc") }}/screngn__xcd_bil_des_reason.csv')
)

select *
from raw