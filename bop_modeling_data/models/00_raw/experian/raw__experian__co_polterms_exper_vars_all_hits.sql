
with

raw as (
    select *
    from read_csv_auto('{{ var("raw_csv_loc") }}/experian.csv')
)

select *
from raw