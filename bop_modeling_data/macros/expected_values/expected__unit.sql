{%- macro expected__unit(type) -%}
{%- set var = 'unit' -%}
{%- if type == 'raw' -%}
    ['Missing','CCCC','Small Business','Commercial Lines']
{%- elif type == 'clean' -%}
    ['Missing','CCCC','Small Business']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{%- endmacro -%}
