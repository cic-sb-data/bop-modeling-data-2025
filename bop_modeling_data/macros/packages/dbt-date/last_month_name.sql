{%- macro date__last_month_name(short=True, tz=None) -%}
{{ date__month_name(date__last_month(tz), short=short) }}
{%- endmacro -%}
