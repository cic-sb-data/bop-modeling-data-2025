{%- macro date__now(tz=None) -%}
{{ date__convert_timezone(dbt.current_timestamp(), tz) }}
{%- endmacro -%}
