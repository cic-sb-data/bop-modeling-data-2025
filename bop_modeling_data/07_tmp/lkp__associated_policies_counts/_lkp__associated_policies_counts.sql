
with

associated_policies as (
    select * exclude (add_final_associated_policy_key__nrows)
    from {{ ref('_lkp__associated_policies_counts__add_final_associated_policy_key') }}
)

select *
from associated_policies