{# timestamp  -------------------------------------------------     #}
{%- macro type_timestamp() -%}
  {{ return(adapter.dispatch('type_timestamp')()) }}
{%- endmacro -%}

{% macro default__type_timestamp() -%}
    timestamp
{%- endmacro %}

{% macro snowflake__type_timestamp() -%}
    timestamp_ntz
{%- endmacro %}

{% macro postgres__type_timestamp() -%}
    timestamp without time zone
{%- endmacro %}

{% macro trino__type_timestamp() -%}
    timestamp(3)
{%- endmacro %}

{# datetime  -------------------------------------------------     #}

{% macro type_datetime() -%}
  {{ return(adapter.dispatch('type_datetime')()) }}
{%- endmacro %}

{% macro default__type_datetime() -%}
    datetime
{%- endmacro %}

{# see: https://docs.snowflake.com/en/sql-reference/data-types-datetime.html#datetime #}
{% macro snowflake__type_datetime() -%}
    timestamp_ntz
{%- endmacro %}

{% macro postgres__type_datetime() -%}
    timestamp without time zone
{%- endmacro %}

{% macro duckdb__type_datetime() -%}
    timestamp
{%- endmacro %}

{% macro spark__type_datetime() -%}
    timestamp
{%- endmacro %}

{% macro trino__type_datetime() -%}
    timestamp(3)
{%- endmacro %}
