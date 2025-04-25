with

raw as (
    select 
        bil_account_id,
        bil_account_id_hash,
        * exclude(
            bil_account_id,
            bil_account_id_hash
        ) 

    from read_csv_auto('{{ var("raw_csv_loc") }}/screngn__xcd_bil_cash_receipt.csv')
)

select *
from raw