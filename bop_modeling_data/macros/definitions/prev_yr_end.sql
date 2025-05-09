{% macro prev_yr_end(date_col, prior_year=1) -%}
    {%- set yr= prior_year + 1 -%}
    {{ date_col }} - interval {{ yr }} years
{%- endmacro %}

{% macro prev_yr_end_1toN(date_col, N=5) %}
    {%- for i in range(N) -%}
        {%- set yr= i + 1 -%}
        {{ prev_yr_end(date_col, prior_year=yr) }} as prev_{{ yr }}yr_end{%- if not loop.last %},{% endif -%}
    {%- endfor -%}
{% endmacro %}