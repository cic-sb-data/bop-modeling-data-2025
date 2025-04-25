with

raw as (
    select 
        *

    from read_csv_auto('{{ var("raw_csv_loc") }}/screngn__xcd_bil_policy_trm.csv')
)

select *
from raw