{%- macro date__convert_timezone(column, target_tz=None, source_tz=None) -%}
{%- set source_tz = "UTC" if not source_tz else source_tz -%}
{%- set target_tz = var("date__time_zone") if not target_tz else target_tz -%}
{{ adapter.dispatch('date__convert_timezone') (column, target_tz, source_tz) }}
{%- endmacro -%}

{% macro default__date__convert_timezone(column, target_tz, source_tz) -%}
convert_timezone('{{ source_tz }}', '{{ target_tz }}',
    cast({{ column }} as {{ dbt.type_timestamp() }})
)
{%- endmacro -%}

{%- macro bigquery__date__convert_timezone(column, target_tz, source_tz=None) -%}
timestamp(datetime({{ column }}, '{{ target_tz}}'))
{%- endmacro -%}

{% macro postgres__date__convert_timezone(column, target_tz, source_tz) -%}
cast(
    cast({{ column }} as {{ dbt.type_timestamp() }})
        at time zone '{{ source_tz }}' at time zone '{{ target_tz }}' as {{ dbt.type_timestamp() }}
)
{%- endmacro -%}

{%- macro redshift__date__convert_timezone(column, target_tz, source_tz) -%}
{{ return(default__date__convert_timezone(column, target_tz, source_tz)) }}
{%- endmacro -%}

{% macro duckdb__date__convert_timezone(column, target_tz, source_tz) -%}
{{ return(postgres__date__convert_timezone(column, target_tz, source_tz)) }}
{%- endmacro -%}

{%- macro spark__date__convert_timezone(column, target_tz, source_tz) -%}
from_utc_timestamp(
        to_utc_timestamp({{ column }}, '{{ source_tz }}'),
        '{{ target_tz }}'
        )
{%- endmacro -%}

{%- macro trino__date__convert_timezone(column, target_tz, source_tz) -%}
    cast((at_timezone(with_timezone(cast({{ column }} as {{ dbt.type_timestamp() }}), '{{ source_tz }}'), '{{ target_tz }}')) as {{ dbt.type_timestamp() }})
{%- endmacro -%}
