{% macro expected__cinergy_role_name(type) %}
{%- set var = 'cinergy_role_name' -%}
{%- if type == 'raw' -%}
    [
        'Cinergy Small Business CCC User Role',
        'Missing',
        'eVolve Small Business Agent',
        'eVolve Small Business All Delegates',
        'eVolve Small Business Field',
        'eVolve Small Business Underwriting'
    ]
{%- elif type == 'clean' -%}
    [
        'Cinergy Small Business CCC User Role',
        'eVolve Small Business Agent',
        'eVolve Small Business All Delegates',
        'eVolve Small Business Field',
        'eVolve Small Business Underwriting'
    ]
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}