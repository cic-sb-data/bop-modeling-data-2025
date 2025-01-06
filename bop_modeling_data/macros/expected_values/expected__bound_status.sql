{% macro expected__bound_status(type) %}
{%- set var = 'bound_status' -%}
{%- if type == 'raw' -%}
    ['Missing', 'Bound', 'Not Bound']
{%- elif type == 'clean' -%}
    ['Missing', 'Bound', 'Not Bound']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
