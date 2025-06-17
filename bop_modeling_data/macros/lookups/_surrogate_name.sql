{# Generate a surrogate name based on column names
   ------------------------------------------------------------
   This macro generates a surrogate name for the lookup table based on the provided column names.
   If no surrogate name is provided, it defaults to a combination of the first column name and '_id'.
   If multiple columns are provided, it defaults to 'surrogate_id'. #}
{% macro _lookups__surrogate_name(id_col_name, column_names ) -%}
    {% if column_names | length == 1 %}
        {{ column_names[0] ~ '_id' }}
    {% else %}
        {{ id_col_name }}
    {% endif %}
{%- endmacro %}
