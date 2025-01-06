{%- macro date__next_month_name(short=True, tz=None) -%}
{{ date__month_name(date__next_month(tz), short=short) }}
{%- endmacro -%}
