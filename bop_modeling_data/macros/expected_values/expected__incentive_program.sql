{% macro expected__incentive_program(type) %}
{%- set var = 'incentive_program' -%}
{%- if type == 'raw' -%}
    ['Missing', 'Post-Incentive Program', 'Pre-Incentive Program']
{%- elif type == 'clean' -%}
    ['Missing', 'Post-Incentive Program', 'Pre-Incentive Program']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
