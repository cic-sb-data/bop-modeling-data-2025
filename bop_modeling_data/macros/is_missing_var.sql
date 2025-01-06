{%- macro is_missing_var(column) -%}

{%- if column[:2] == 'is' -%}
    {%- set new_column_name = column ~ '_missing'-%}
{%- else -%}
    {%- set new_column_name = 'is_' ~ column ~ '_missing'-%}
{%- endif -%}

case
    when {{ column }} is null then 1
    when try_cast({{ column }} as text) = 'Missing' then 1
    else 0
end as {{ new_column_name }},

{%- endmacro -%}