
{% macro bil_acct_key(bil_account_id='BIL_ACCOUNT_ID') -%}
    md5_number({{ bil_account_id }}) as bil_acct_key
{%- endmacro %}