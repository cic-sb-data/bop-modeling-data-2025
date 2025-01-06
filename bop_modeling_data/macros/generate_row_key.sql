{%- macro generate_row_key(quote_numb, quote_version_numb, policy_sym) -%}

hash({{ quote_numb }} || {{ quote_version_numb }} || {{ policy_sym }} ) as row_key

{%- endmacro -%}