{%- macro date__day_of_month(date) -%}
{{ date__date_part('day', date) }}
{%- endmacro %}

{%- macro redshift__date__day_of_month(date) -%}
cast({{ date__date_part('day', date) }} as {{ dbt.type_bigint() }})
{%- endmacro %}
