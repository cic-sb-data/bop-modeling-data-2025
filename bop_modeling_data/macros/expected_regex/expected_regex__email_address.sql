{%- macro expected_regex__email_address() -%}
{%- set return_value='([a-zA-Z0-9._+]+@[a-zA-Z0-9+\-]+\.[a-zA-Z0-9]+|Missing|Excluded)' -%}
{{ return_value }}
{%- endmacro -%}