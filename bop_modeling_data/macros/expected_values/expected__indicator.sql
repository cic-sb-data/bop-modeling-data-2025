{% macro expected__indicator(type) %}
{%- set var = 'indicator' -%}
{%- if type == 'yes_no' -%}
    ['Missing', 'Yes', 'No']
{%- elif type == 'yn' -%}
    ['Missing', 'Y', 'N']
{%- elif type == 'float' -%}
    [1.0, 0.0, null]
{%- elif type == 'int' -%}
    [0, 1, null]
{%- elif type == 'clean' -%}
    [0, 1]
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
