{% macro expected__quote_age(type) %}
{%- set var = 'quote_age' -%}
{%- if type == 'raw' -%}
    ['a) Last 30 days' ,'b) 31 to 60 days' ,'c)  61 to 90 days' ,'d) > 90 days']
{%- elif type == 'clean' -%}
    ['a) Last 30 days' ,'b) 31 to 60 days' ,'c)  61 to 90 days' ,'d) > 90 days']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}