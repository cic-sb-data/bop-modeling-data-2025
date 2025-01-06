{% macro expected__tier_group(type) %}
{%- set var = 'tier_group' -%}
{%- if type == 'raw' -%}
    ['Missing', '0 - 10', '10 - 20', '20 - 30']
{%- elif type == 'clean' -%}
    ['Missing', '0 - 10', '10 - 20', '20 - 30']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
