{%- macro sigmoid(old_column_name, new_column_name) -%}
(1 / (1 + exp(- {{ old_column_name }}))) as {{ new_column_name }}
{%- endmacro -%}

