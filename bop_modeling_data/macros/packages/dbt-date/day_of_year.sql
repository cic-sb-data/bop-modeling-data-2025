{%- macro date__day_of_year(date) -%}
{{ adapter.dispatch('date__day_of_year') (date) }}
{%- endmacro %}

{%- macro default__date__day_of_year(date) -%}
    {{ date__date_part('dayofyear', date) }}
{%- endmacro %}

{%- macro postgres__date__day_of_year(date) -%}
    {{ date__date_part('doy', date) }}
{%- endmacro %}

{%- macro redshift__date__day_of_year(date) -%}
    cast({{ date__date_part('dayofyear', date) }} as {{ dbt.type_bigint() }})
{%- endmacro %}

{%- macro spark__date__day_of_year(date) -%}
    dayofyear({{ date }})
{%- endmacro %}

{%- macro trino__date__day_of_year(date) -%}
    {{ date__date_part('day_of_year', date) }}
{%- endmacro %}
