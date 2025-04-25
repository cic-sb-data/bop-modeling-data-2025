{%- macro col_and_is_col_missing(column_name) -%}

{%- if column_name[0:3] != 'is_' -%}
    {%- set missing_col_prefix = '' -%}
{%- else -%}
    {%- set missing_col_prefix = 'is_' -%}
{%- endif -%}

{%- set missing_col_name = missing_col_prefix ~ column_name ~ '_missing' -%}


{{ column_name }},
{{ missing_col_name }}
{%- endmacro -%}
