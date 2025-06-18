
with

raw as (
    select *
    from read_csv_auto('{{ var("raw_csv_loc") }}/experian.csv', sample_size=1000000, ignore_errors=true)
)

select *
from raw