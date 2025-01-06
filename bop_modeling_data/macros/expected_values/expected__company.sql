{% macro expected__company(type) %}
{%- set var = 'company' -%}
{%- if type == 'number' -%}
    [3, 5, 7, 0]
{%- elif type == 'code' -%}
    [
        'Missing',
        'CIC', 'CID', 'CCC',
        'cic', 'cid', 'ccc'
    ]
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
