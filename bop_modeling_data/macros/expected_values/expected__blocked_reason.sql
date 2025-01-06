{% macro expected__blocked_reason(type) %}
{%- set var = 'blocked_reason' -%}
{%- if type == 'raw'  -%}
    [
        'Missing',
        'BOP policy must first be created',
        'Cinergy Cust product match',
        'Cust Match w different agent/Enterprise Submissions',
        'Cust Match/Enterprise Submissions'
    ]
{%- elif type == 'clean' -%}
    [
        'Missing',
        'BOP policy must first be created',
        'Cinergy Cust product match',
        'Cust Match w different agent/Enterprise Submissions',
        'Cust Match/Enterprise Submissions'
    ]
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
