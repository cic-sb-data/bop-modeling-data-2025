{%- macro raw_policyid_quoteid() -%}
with

raw as (
    select
        {{ generate_row_key('submission_quote_numb', 'quote_version_numb', 'submission_policy_sym')}},
        {{ generate_quote_key('submission_quote_numb', 'quote_version_numb') }},
        *
    from {{ ref('stg__tblquotes_hitratio_sb') }}
),

policy as (
    select quote_id, policy_id
    from {{ ref('policy') }}
),

quote as (
    select q.quote_id, q.quote_key, p.policy_id
    from {{ ref('quote') }} as q
    left join policy as p
        on q.quote_id = p.quote_id
),

join_quote_id as (
    select
        quote.*,
        raw.* exclude (quote_key)

    from quote
    left join raw
        on quote.quote_key = raw.quote_key 
)

from join_quote_id

{%- endmacro -%}