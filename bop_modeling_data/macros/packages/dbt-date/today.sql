{%- macro date__today(tz=None) -%}
cast({{ date__now(tz) }} as date)
{%- endmacro -%}
