{% macro expected__naics_source_desc(type) %}
{%- set var = 'naics_source_desc' -%}
{%- if type == 'raw' -%}
    ['Experian Overridden', 'Experian Primary', 'Experian Secondary', 'Missing']
{%- elif type == 'clean' -%}
    ['Experian Overridden', 'Experian Primary', 'Experian Secondary', 'Missing']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
