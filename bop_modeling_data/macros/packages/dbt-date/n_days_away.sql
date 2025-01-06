{%- macro date__n_days_away(n, date=None, tz=None) -%}
{{ date__n_days_ago(-1 * n, date, tz) }}
{%- endmacro -%}
