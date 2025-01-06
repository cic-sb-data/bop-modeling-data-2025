{% macro expected__cld_territory(type) %}
{%- set var = 'cld_territory' -%}
{%- if type == 'raw' -%}
    ['Midwest', 'Missing', 'North', 'Northeast', 'Southeast', 'West']
{%- elif type == 'clean' -%}
    ['Midwest', 'North', 'Northeast', 'Southeast', 'West']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
