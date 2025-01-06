{%- macro expected_regex__zip_code(type) -%}
    {%- if type == 'zip_code' -%}
        {%- set zip_code_patterns = '^\d{5}$' -%}
    {%- elif type == 'zip_plus_four_code' -%}
        {%- set zip_code_patterns = '((^\d{9}$)|(^\d{5}[-\s]\d{4}$))' -%}
    {%- elif type == 'zip_extension' -%}
        {%- set zip_code_patterns = '^\d{4}$' -%}
    {%- elif type == 'raw' -%}
        {%- set zip_code_patterns = '(^\d{5}$|^\d{9}$|^\d{5}[-\s]\d{4}$|Missing|(OH|NC))' -%}
    {%- else -%}
        {%- set zip_code_patterns = '(^\d{5}$|^\d{9}$|^\d{5}[-\s]\d{4}$|Missing|(OH|NC))' -%}
    {%- endif -%}
    {{ zip_code_patterns }}
{%- endmacro -%}
