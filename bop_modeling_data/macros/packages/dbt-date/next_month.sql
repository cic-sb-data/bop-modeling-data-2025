{%- macro date__next_month(tz=None) -%}
{{ date__n_months_away(1, tz) }}
{%- endmacro -%}
