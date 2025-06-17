-- depends_on: {{ ref('xcd_bil_acct_key') }}

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
)

select *
from raw