{% macro expected__blocked_status(type) %}
{%- set var = 'blocked_status' -%}
{%- if type == 'raw'  -%}
    ['Missing', 'Blocked', 'Unblocked']
{%- elif type == 'clean' -%}
    ['Missing', 'Blocked', 'Unblocked']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
