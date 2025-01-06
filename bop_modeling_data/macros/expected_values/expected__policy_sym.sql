{% macro expected__policy_sym(type) %}
{%- set var = 'policy_sym' -%}
{%- if type == 'raw' -%}
    ['Missing', 'SBA', 'SBB', 'SBW', 'SBU']
{%- elif type == 'clean' -%}
    ['SBA', 'SBB', 'SBW', 'SBU']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
