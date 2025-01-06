{% macro expected__occupancy_desc(type) %}
{%- set var = 'occupancy_desc' -%}
{%- if type == 'raw' -%}
    ['LRO', 'LRO-BPP only', 'LRO-occupant', 'Owner occupied', 'Tenant']
{%- elif type == 'clean' -%}
    ['LRO', 'LRO-BPP only', 'LRO-occupant', 'Owner occupied', 'Tenant']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
