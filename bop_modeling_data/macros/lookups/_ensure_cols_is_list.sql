{# Ensure column names are in a list
   ------------------------------------------------------------
   This macro ensures that the column names are provided as a list.
   If a single string is provided, it converts it to a list with one element.
   If a list is already provided, it returns it as is. #}
{% macro _lookups__ensure_cols_is_list(column_names) -%}
    {% if column_names is string %}
        {# Raise an error telling the user to use a list #}
        {%- set model_name = this.name | replace('bop_modeling_data.', '') -%}
        {% set exceptions = load_macro('dbt.exceptions') %}
        {% do exceptions.raise_compiler_error(
            'Column names must be provided as a list. '
            'If you are using a single column, please wrap it in a list, e.g., ["column_name"].'
        ) %}
    {% elif column_names is not iterable %}
        {# Raise an error telling the user to use a list #}
        {%- set model_name = this.name | replace('bop_modeling_data.', '') -%}
        {% set exceptions = load_macro('dbt.exceptions') %}
        {% do exceptions.raise_compiler_error(
            'Column names must be provided as a list. '
            'If you are using a single column, please wrap it in a list, e.g., ["column_name"].'
        ) %}
    {% else %}
        {# Ensure column_names is a list #}
        {% set cols = column_names if column_names is iterable else [column_names] %}
        {# Remove duplicates and sort the list #}
        {% set cols = cols | unique | sort %}
    {% endif %}
    {# Return cols as a list, not a string #}
    {{ return(cols) }}
{%- endmacro %}
