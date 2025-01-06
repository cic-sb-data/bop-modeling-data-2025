{% macro date__date_part(datepart, date) -%}
    {{ adapter.dispatch('date__date_part') (datepart, date) }}
{%- endmacro %}

{% macro default__date__date_part(datepart, date) -%}
    date_part('{{ datepart }}', {{  date }})
{%- endmacro %}

{% macro bigquery__date__date_part(datepart, date) -%}
    extract({{ datepart }} from {{ date }})
{%- endmacro %}

{% macro trino__date__date_part(datepart, date) -%}
    extract({{ datepart }} from {{ date }})
{%- endmacro %}
