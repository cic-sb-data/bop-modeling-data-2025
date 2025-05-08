with

{{ with_ref('stg__cur_cb', 'raw') }},
{{ with_ref('lkp__dates', 'dates') }},

add_activity_transaction_key as (
    select distinct
        md5_number(
            try_cast(billing_acct_key as varchar)
            || try_cast(year(billing_activity_date) as varchar)
            || try_cast(month(billing_activity_date) as varchar)
            || try_cast(day(billing_activity_date) as varchar)
            || try_cast(billing_sb_policy_key as varchar)
            || try_cast(associated_policy_key as varchar)
            || try_cast(associated_sb_policy_key as varchar)
            || try_cast(billing_policy_key as varchar)
        ) as activity_trans_key,
        associated_policy_key,
        associated_sb_policy_key,
        billing_activity_date,
        billing_activity_amt,
        -- Pass through NPC-related columns from the raw source
        bil_acy_des_cd,
        bil_des_rea_typ

    from raw
    order by 
        associated_policy_key,
        associated_sb_policy_key,
        billing_activity_date
),

filtered_npc_events as (
    select
        *
    from add_activity_transaction_key
    where bil_acy_des_cd = 'C' and bil_des_rea_typ = '' -- SAS-derived NPC definition
)

select *
from filtered_npc_events