{% macro expected__policy_status_desc(type) %}
{%- set var = 'policy_status_desc' -%}
{%- if type == 'raw' -%}
    ['Missing', 'Declined', 'Issued', 'Pending', 'Quoted', 'Quoted but not written', 'Submitted but not quoted']
{%- elif type == 'clean' -%}
    ['Declined', 'Issued', 'Pending', 'Quoted', 'Quoted but not written', 'Submitted but not quoted']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
