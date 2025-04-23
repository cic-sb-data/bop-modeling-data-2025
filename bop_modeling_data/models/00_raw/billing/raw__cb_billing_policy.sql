with

raw as (
    select 
        *

    from read_csv_auto('{{ var("raw_csv_loc") }}/decfile.billing_policy.csv')
)

select * 
from raw