{%- macro is_value_positive(column_name) -%}
case when {{ column_name }} > 0 then 1 else 0 end as is_{{ column_name | replace('_', '') }}_positive
{%- endmacro -%}