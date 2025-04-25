{%- macro expected_regex__n_digit_code(n) -%}
{%- set return_value='(\d{' ~ n ~ '}|Missing|Excluded)' -%}
{{ return_value }}
{%- endmacro -%}