{% macro expected__referral_status(type) %}
{%- set var = 'referral_status' -%}
{%- if type == 'raw'  -%}
    ['Missing', 'Referral', 'Not Referred']
{%- elif type == 'clean' -%}
    ['Missing', 'Referral', 'Not Referred']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
