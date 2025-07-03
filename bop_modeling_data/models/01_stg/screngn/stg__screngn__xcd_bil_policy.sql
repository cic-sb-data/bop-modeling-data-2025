-- depends_on: {{ ref('lkp__bil_acct_key') }}

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

    from {{ ref('raw__screngn__xcd_bil_policy') }}
),

recode_and_rename as (
    select
        bil_account_id as bil_acct_id,
        bil_account_nbr as bil_acct_numb,
        xcd_policy_id as bil_policy_id,
        pol_symbol_cd as policy_sym,
        pol_nbr as policy_numb,
        cur_bil_plan_cd as bil_plan_code,
        bil_issue_ind as bil_issue

    from raw
)

select *
from recode_and_rename