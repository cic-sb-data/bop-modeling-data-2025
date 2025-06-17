{# Ensure column names are in a list
   ------------------------------------------------------------
   This macro ensures that the column names are provided as a list.
   If a single string is provided, it converts it to a list with one element.
   If a list is already provided, it returns it as is. #}
{% macro _lookups__ensure_cols_is_list(column_names) -%}
    {% if column_names is string %}
        {% set cols = [column_names] %}
    {% else %}
        {% set cols = column_names %}
    {% endif %}
    {{ cols }}
{%- endmacro %}
