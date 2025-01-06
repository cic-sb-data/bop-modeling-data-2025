{% macro expected__premium_band(type) %}
{%- set var = 'premium_band' -%}
{%- if type == 'raw' -%}
    ['Missing', 'a.) $0-2,499',  'b.) $2,500-4,999',  'c.) $5,000-9,999',  'd.) $10,000-24,999',  'e.) $25,000-49,999',  'f.) $50,000-99,999',  'g.) $100,000+']
{%- elif type == 'clean' -%}
    ['a.) $0-2,499',  'b.) $2,500-4,999',  'c.) $5,000-9,999',  'd.) $10,000-24,999',  'e.) $25,000-49,999',  'f.) $50,000-99,999',  'g.) $100,000+']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}