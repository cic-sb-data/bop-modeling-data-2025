{%- macro dev_date_filter(date_col) -%}
    {%- if target.name == 'dev' -%}
        date_sub('month', {{ date_col }}, current_date) <= 12
    {%- else -%}
        1=1
    {%- endif -%}
{%- endmacro -%}