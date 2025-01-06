{%- macro expected_regex__month() -%}
{%- set return_value='([1-2]\d{3}-[01]\d|Missing|Excluded)' -%}
{{ return_value }}
{%- endmacro -%}