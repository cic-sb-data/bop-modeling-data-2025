{% macro expected__transaction_type(type) %}
{%- set var = 'transaction_type' -%}
{%- if type == 'raw' -%}
    ['Missing', 'Tarmika', 'None']
{%- elif type == 'xml_raw' -%}
    ['Missing', 'Tarmika', 'None']
{%- elif type == 'clean' -%}
    ['Missing', 'Tarmika', 'None']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}