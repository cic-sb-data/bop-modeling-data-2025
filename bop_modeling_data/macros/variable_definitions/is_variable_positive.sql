{# This macro checks if a variable is positive and returns 1 if it is, otherwise returns 0. #}

{%- macro is_variable_positive(col) -%}
case when {{ col }} > 0 then 1 else 0 end 
{%- endmacro -%}
