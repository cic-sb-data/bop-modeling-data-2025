{# Generate a surrogate name based on column names
   ------------------------------------------------------------
   This macro generates a surrogate name for the lookup table based on the provided column names.
   If no surrogate name is provided, it defaults to a combination of the first column name and '_id'.
   If multiple columns are provided, it defaults to 'surrogate_id'. #}
{% macro _lookups__surrogate_name(id_col_name, column_names ) -%}
    {%- if column_names | length == 1 -%}
        {%- set surrogate_name = column_names[0] ~ '_id' -%}
    {%- else -%}
        {%- set surrogate_name = id_col_name -%}
    {%- endif -%}

    {%- set clean_surrogate_name = __clean_text(surrogate_name) -%}
    {%- set surrogate_name = 'lkp__' ~ clean_surrogate_name -%}

    {%- if surrogate_name | length > 63 -%}
        {%- set surrogate_name = surrogate_name[:63] -%}
    {%- endif -%}

    {{ surrogate_name }}

{%- endmacro -%}

{%- macro __clean_text(text) -%}
    {%- set cleaned_text = text | trim | lower | replace(' ', '_') -%}
    {{ cleaned_text }}
{%- endmacro -%}
