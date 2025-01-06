{%- macro date__last_week(tz=None) -%}
{{ date__n_weeks_ago(1, tz) }}
{%- endmacro -%}
