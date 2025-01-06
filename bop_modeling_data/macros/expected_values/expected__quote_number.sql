{% macro expected__quote_numb(type) %}
{%- set var = 'quote_numb' -%}
{%- if type == 'regex' -%}
    ['Missing', '\d{7}']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
