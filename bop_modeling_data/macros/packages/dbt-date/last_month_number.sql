{%- macro date__last_month_number(tz=None) -%}
{{ date__date_part('month', date__last_month(tz)) }}
{%- endmacro -%}
