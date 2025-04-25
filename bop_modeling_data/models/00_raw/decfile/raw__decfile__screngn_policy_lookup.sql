with

raw as (
    select 
        *

    from read_csv_auto('{{ var("raw_csv_loc") }}/decfile.screngn_policy_lookup.csv')
)

select * 
from raw