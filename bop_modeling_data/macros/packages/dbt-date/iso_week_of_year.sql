{%- macro date__iso_week_of_year(date=None, tz=None) -%}
{%-set dt = date if date else date__today(tz) -%}
{{ adapter.dispatch('date__iso_week_of_year') (dt) }}
{%- endmacro -%}

{%- macro _iso_week_of_year(date, week_type) -%}
cast({{ date__date_part(week_type, date) }} as {{ dbt.type_int() }})
{%- endmacro %}

{%- macro default__date__iso_week_of_year(date) -%}
{{ _iso_week_of_year(date, 'isoweek') }}
{%- endmacro %}

{%- macro snowflake__date__iso_week_of_year(date) -%}
{{ _iso_week_of_year(date, 'weekiso') }}
{%- endmacro %}

{%- macro postgres__date__iso_week_of_year(date) -%}
-- postgresql week is isoweek, the first week of a year containing January 4 of that year.
{{ _iso_week_of_year(date, 'week') }}
{%- endmacro %}

{%- macro duckdb__date__iso_week_of_year(date) -%}
{{ return(postgres__date__iso_week_of_year(date)) }}
{%- endmacro %}

{%- macro spark__date__iso_week_of_year(date) -%}
{{ _iso_week_of_year(date, 'week') }}
{%- endmacro %}

{%- macro trino__date__iso_week_of_year(date) -%}
{{ _iso_week_of_year(date, 'week') }}
{%- endmacro %}
