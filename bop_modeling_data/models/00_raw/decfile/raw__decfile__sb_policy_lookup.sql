with

raw as (
    select
        *

    from read_csv_auto('{{ var("raw_csv_loc") }}/decfile.policy_lookup.csv')
)

select *
from raw