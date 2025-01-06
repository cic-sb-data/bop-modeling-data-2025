{% macro expected__construction_type(type) %}
{%- set var = 'construction_type' -%}
{%- if type == 'raw' -%}
    [
        'Fire Resistive',
        'Frame',
        'Joisted Masonry',
        'MASONRY',
        'Masonry Noncombustible',
        'Missing',
        'Modified Fire Resistive',
        'Noncombustible'
    ]
{%- elif type == 'clean' -%}
    [
        'Fire Resistive',
        'Frame',
        'Masonry-Joisted',
        'Masonry',
        'Masonry-Noncombustible',
        'Modified Fire Resistive',
        'Noncombustible'
    ]
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
