with

raw as (
    select 
        bil_account_id,
        bil_account_id_hash,
        * exclude(
            bil_account_id,
            bil_account_id_hash
        ) replace (
            try_cast(POL_NBR as ubigint) as POL_NBR
        )

    from read_csv_auto('{{ var("raw_csv_loc") }}/screngn__xcd_bil_policy.csv')
)

select *
from raw