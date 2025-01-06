{% macro expected__uw_method_code(type) %}
{%- set var = 'uw_method_code' -%}
{%- if type == 'raw' -%}
    ['Missing', 'Tenant']
{%- elif type == 'clean' -%}
    ['Missing', 'Tenant']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
