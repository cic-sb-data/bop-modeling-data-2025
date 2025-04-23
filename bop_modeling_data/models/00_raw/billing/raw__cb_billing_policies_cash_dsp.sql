with

raw as (
    select 
        -- cincibill_policy_id,
        *


    from read_csv_auto('{{ var("raw_csv_loc") }}/decfile.billing_policies_cash_dsp.csv')
    where billing_acct_id is not null
)

select * 
from raw