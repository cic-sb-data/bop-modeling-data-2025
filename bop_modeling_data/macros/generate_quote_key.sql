{%- macro generate_quote_key(quote_numb, quote_version_numb) -%}

hash({{ quote_numb }} || {{quote_version_numb}} ) as quote_key

{%- endmacro -%}