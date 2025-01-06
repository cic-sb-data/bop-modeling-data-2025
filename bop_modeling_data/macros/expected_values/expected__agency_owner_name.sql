{% macro expected__agency_owner_name(type) %}
{%- set var = 'agency_owner_name' -%}
{%- if type == 'raw' -%}
    ['Missing', 'Owner1', 'Owner2', 'Owner3', 'Owner4']
{%- elif type == 'clean' -%}
    ['Missing', 'Owner1', 'Owner2', 'Owner3', 'Owner4']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
