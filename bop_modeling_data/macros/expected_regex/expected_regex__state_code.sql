{%- macro expected_regex__state_code() -%}
    {%- set return_value = '(([A-Z]{2}|[a-z]{2})|Missing|Excluded)' -%}
    {{ return_value }}
{%- endmacro -%}
