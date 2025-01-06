{% macro expected__occupancy_ind(type) %}
{%- set var = 'occupancy_ind' -%}
{%- if type == 'raw' -%}
    ['LRO', 'LRO+BPP', 'LRO+Building', 'LRO+Building+BPP', 'Non-LRO', 'Non-LRO+BPP', 'Non-LRO+Building', 'Non-LRO+Building+BPP']
{%- elif type == 'clean' -%}
    ['LRO', 'LRO+BPP', 'LRO+Building', 'LRO+Building+BPP', 'Non-LRO', 'Non-LRO+BPP', 'Non-LRO+Building', 'Non-LRO+Building+BPP']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
