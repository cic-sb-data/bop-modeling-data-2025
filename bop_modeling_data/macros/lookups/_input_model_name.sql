{# Generate input model name based on root
   ------------------------------------------------------------
   This macro generates an input model name based on the provided root.
   It prefixes the root with 'raw__' to create a consistent naming convention for raw data models. #}
{% macro _lookups__input_model_name(root) -%}
    'raw__' ~ root
{%- endmacro %}
