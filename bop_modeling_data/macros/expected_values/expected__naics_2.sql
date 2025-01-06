{% macro expected__naics_2(type) %}
{%- set var = 'naics_2' -%}
{%- if type == 'raw' -%}
    ['Missing', '23']
{%- elif type == 'clean' -%}
    ['Missing', '23']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
