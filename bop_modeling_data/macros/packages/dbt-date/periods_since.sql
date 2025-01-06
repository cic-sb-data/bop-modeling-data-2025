{%- macro date__periods_since(date_col, period_name='day', tz=None) -%}
{{ dbt.datediff(date_col, date__now(tz), period_name) }}
{%- endmacro -%}
