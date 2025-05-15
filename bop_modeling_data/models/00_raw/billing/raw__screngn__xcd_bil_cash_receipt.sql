with

raw as (
    select *
    from read_csv_auto('{{ var("raw_csv_loc") }}/screngn__xcd_bil_cash_receipt.csv')
)

select *
from raw