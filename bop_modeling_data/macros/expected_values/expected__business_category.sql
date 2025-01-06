{% macro expected__business_category(type) %}
{%- set var = 'business_category' -%}
{%- if type == 'raw' -%}
    [   
        'Health Care & Fitness',
        'Professional & Business Services',
        'Real Estate',
        'Restaurants & Food Services',
        'Retail',
        'Services',
        'Wholesale & Distribution'
    ]
{%- elif type == 'clean' -%}
    [
        'Health Care & Fitness',
        'Professional & Business Services',
        'Real Estate',
        'Restaurants & Food Services',
        'Retail',
        'Services',
        'Wholesale & Distribution'
    ]
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
