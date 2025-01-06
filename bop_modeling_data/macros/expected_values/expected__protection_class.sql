{% macro expected__protection_class(type) %}
{%- set var = 'protection_class' -%}
{%- if type == 'raw' -%}
    ['1', '10', '10W', '1X', '1Y', '2', '2X', '2Y', '3', '3W', '3X', '3Y', '4', '4W', '4X', '4Y', '5', '5W', '5X', '5Y', '6', '6X', '6Y', '7', '7X', '7Y', '8', '8B', '8X', '8Y', '9', '9S', 'Missing']
{%- elif type == 'clean' -%}
    ['1', '10', '10W', '1X', '1Y', '2', '2X', '2Y', '3', '3W', '3X', '3Y', '4', '4W', '4X', '4Y', '5', '5W', '5X', '5Y', '6', '6X', '6Y', '7', '7X', '7Y', '8', '8B', '8X', '8Y', '9', '9S', 'Missing']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
