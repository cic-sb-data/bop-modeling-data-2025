{%- macro date__next_month_number(tz=None) -%}
{{ date__date_part('month', date__next_month(tz)) }}
{%- endmacro -%}
