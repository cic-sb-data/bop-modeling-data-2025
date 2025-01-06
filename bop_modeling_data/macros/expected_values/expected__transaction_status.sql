{% macro expected__transaction_status(type) %}
{%- set var = 'transaction_status' -%}
{%- if type == 'raw' -%}
    ['Missing', 'Active', 'Cancelled', 'Expired', 'Non-Renewed', 'Reinstated', 'Renewed', 'Rewritten']
{%- elif type == 'xml_raw' -%}
    ['Missing', 'Active', 'Cancelled', 'Expired', 'Non-Renewed', 'Reinstated', 'Renewed', 'Rewritten']
{%- elif type == 'clean' -%}
    ['Missing', 'Active', 'Cancelled', 'Expired', 'Non-Renewed', 'Reinstated', 'Renewed', 'Rewritten']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
