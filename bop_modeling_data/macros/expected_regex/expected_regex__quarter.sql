{%- macro expected_regex__quarter() -%}
{%- set return_value='([12]\d{3}-Q[1-4]|Missing|Excluded)' -%}
{{ return_value }}
{%- endmacro -%}