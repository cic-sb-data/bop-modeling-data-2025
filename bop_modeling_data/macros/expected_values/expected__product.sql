{% macro expected__product(type) %}
{%- set var = 'product' -%}
{%- if type == 'raw' -%}
    ['Auto',  'Businessowners',  'Umbrella',  'Work Comp', 'Missing']
{%- elif type == 'clean' -%}
    ['Auto',  'Businessowners',  'Umbrella',  'Work Comp']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
