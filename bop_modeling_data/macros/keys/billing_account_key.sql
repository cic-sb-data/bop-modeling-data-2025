
{% macro billing_account_key(bil_account_id='BIL_ACCOUNT_ID') -%}
    md5_number({{ bil_account_id }}) as billing_account_key
{%- endmacro %}