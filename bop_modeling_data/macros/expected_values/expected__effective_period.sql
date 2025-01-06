{% macro expected__effective_period(type) %}
{%- set var = 'effective_period' -%}
{%- if type == 'raw' -%}
    ['Missing', 'Today', 'Before Today', 'After Today']
{%- elif type == 'raw2' -%}
    ['a) Last 7 days', 'b) Today', 'c) Next 7 days', 'd) 8+ days in past', 'e) 8+ days in future']
{%- elif type == 'clean' -%}
    ['Missing', 'Today', 'Before Today', 'After Today']
{%- elif type == 'clean2' -%}
    ['a) Last 7 days', 'b) Today', 'c) Next 7 days', 'd) 8+ days in past', 'e) 8+ days in future']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
