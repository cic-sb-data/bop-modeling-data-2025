{%- macro date__last_month(tz=None) -%}
{{ date__n_months_ago(1, tz) }}
{%- endmacro -%}
