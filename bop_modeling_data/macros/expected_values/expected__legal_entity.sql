{% macro expected__legal_entity(type) %}
{%- set var = 'legal_entity' -%}
{%- if type == 'raw' -%}
    [
        '501c Nonprofit',
        'Association',
        'Corporation',
        'Individual',
        'Joint Venture',
        'Limited Liability Company',
        'Limited Liability Partner',
        'Limited Partnership',
        'Missing',
        'Non Profit Organization',
        'Organization (any other)',
        'Other',
        'PLLC',
        'Partnership',
        'Trust'
    ]
{%- elif type == 'clean' -%}
    [
        '501c Nonprofit',
        'Association',
        'Corporation',
        'Individual',
        'Joint Venture',
        'Limited Liability Company',
        'Limited Liability Partner',
        'Limited Partnership',
        'Missing',
        'Non Profit Organization',
        'Organization (any other)',
        'Other',
        'PLLC',
        'Partnership',
        'Trust'
    ]
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}