{%- macro expected_regex__full_policy_numb() -%}
{%- set return_value='SB[A|B|U|W]\d{7}|SB[A|B|U|W]' -%}
{{ return_value }}
{%- endmacro -%}