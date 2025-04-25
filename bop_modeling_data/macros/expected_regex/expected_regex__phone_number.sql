{%- macro expected_regex__phone_number() -%}
{%- set return_value='(\(?\d{3}\)?[ -.]?\d{3}[ -.]?\d{4}|Missing|Excluded)' -%}
{{ return_value }}
{%- endmacro -%}