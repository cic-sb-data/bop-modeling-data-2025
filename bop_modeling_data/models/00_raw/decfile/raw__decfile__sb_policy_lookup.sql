with

raw as (
    select
        sb_policy_key,
        policy_chain_id,
        lob,
        company_numb,
        policy_sym,
        policy_numb,
        policy_module,
        policy_eff_date

    from read_csv_auto('{{ var("raw_csv_loc") }}/decfile.policy_lookup.csv')
)

select *
from raw