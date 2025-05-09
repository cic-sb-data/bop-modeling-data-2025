{% macro prev_yr_start(date_col, prior_year=1) -%}
    {{ date_col }} - interval {{ prior_year }} years
{%- endmacro %}


{% macro prev_yr_start_1toN(date_col, N=5) -%}
    {%- for i in range(N) -%}
        {%- set yr= i + 1 -%}
        {{ prev_yr_start(date_col, prior_year=yr) }} as prev_{{ yr }}yr_start{%- if not loop.last %},{% endif -%}
    {%- endfor -%}
{%- endmacro %}