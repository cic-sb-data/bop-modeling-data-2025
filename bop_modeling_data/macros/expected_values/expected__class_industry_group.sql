{% macro expected__class_industry_group(type) %}
{%- set var = 'class_industry_group' -%}
{%- if type == 'raw' -%}
    [   'Health Care & Fitness',
        'Missing',
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