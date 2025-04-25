with

raw as (
    select 
        * replace (
            try_cast(pol_nbr as uinteger) as pol_nbr
        )

    from read_csv_auto('{{ var("raw_csv_loc") }}/screngn__xcd_bil_policy.csv')
)

select *
from raw