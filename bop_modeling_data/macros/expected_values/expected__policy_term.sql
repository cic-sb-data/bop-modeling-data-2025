{% macro expected__policy_term(type) %}
{%- set var = 'policy_term' -%}
{%- if type == 'raw' -%}
    ['1 Year', '3 Year', '3 Years', 'Missing', 'Odd', 'Short']
{%- elif type == 'clean' -%}
    ['1YR', '3YR', 'OTHER', 'NONE']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
