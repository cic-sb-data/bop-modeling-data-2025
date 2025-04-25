{%- macro recode_to_millions(column, new_column) -%}

{%- set one_mil = 1000000.0 -%}
{%- set new_column_name=new_column~'_M' -%}

try_cast(
    try_cast(
        {{ column }} as double
    ) / (
        {{ one_mil }}
    ) as integer
) as {{ new_column_name }}
{%- endmacro -%}