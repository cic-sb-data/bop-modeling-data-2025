{%- macro recode__currency_to_int(column_name) -%}
try_cast(round(100 * try_cast( {{ column_name }} as ubigint), 0) as ubigint)
{%- endmacro -%}
