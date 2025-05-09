
{% macro billing_policy_key(
    policy_id='XCD_POLICY_ID',
    bil_account_id='BIL_ACCOUNT_ID'
) -%}
    md5_number(
        concat(
            {{ policy_id }},
            {{ bil_account_id }}
        )
    ) as billing_policy_key
{%- endmacro %}