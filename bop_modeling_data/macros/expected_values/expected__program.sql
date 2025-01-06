{% macro expected__program(type) %}
{%- set var = 'program' -%}
{%- if type == 'raw' -%}
    ['Missing', 'Small Business']
{%- elif type == 'clean' -%}
    ['Small Business']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
