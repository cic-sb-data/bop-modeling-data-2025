with

raw as (
    select 
        bil_account_id,
        bil_account_id_hash,
        * exclude(
            bil_account_id,
            bil_account_id_hash
        ) 

    from read_csv_auto('{{ var("raw_csv_loc") }}/screngn__xcd_bil_pol_proc_req.csv')
)

select *
from raw