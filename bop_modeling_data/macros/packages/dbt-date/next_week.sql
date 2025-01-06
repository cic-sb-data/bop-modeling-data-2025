{%- macro date__next_week(tz=None) -%}
{{ date__n_weeks_away(1, tz) }}
{%- endmacro -%}
