{% macro expected__comparative_rater(type) %}
{%- set var = 'comparative_rater' -%}
{%- if type == 'raw' -%}
    ['EQCL-PROD', 'Missing', 'No Vendor Name Received', 'Tarmika']
{%- elif type == 'clean' -%}
    ['EQCL-PROD', 'None', 'Tarmika']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
