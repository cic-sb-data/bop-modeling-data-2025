with

raw as (
    select 
        billing_acct_id,
        billing_date,
        policy_sym,
        policy_numb,
        sum(bil_acy_amt) as billed_amt

    from read_csv_auto('{{ var("raw_csv_loc") }}/decfile.billing_acct.csv')
    where billing_acct_id is not null
    group by
        billing_acct_id,
        billing_date,
        policy_sym,
        policy_numb
)

select * 
from raw