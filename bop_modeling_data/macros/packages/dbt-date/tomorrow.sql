{%- macro date__tomorrow(date=None, tz=None) -%}
{{ date__n_days_away(1, date, tz) }}
{%- endmacro -%}
