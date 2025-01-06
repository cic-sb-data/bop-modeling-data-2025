{%- macro date__yesterday(date=None, tz=None) -%}
{{ date__n_days_ago(1, date, tz) }}
{%- endmacro -%}
