{%- macro date__from_unixtimestamp(epochs, format="seconds") -%}
    {{ adapter.dispatch('date__from_unixtimestamp') (epochs, format) }}
{%- endmacro %}

{%- macro default__date__from_unixtimestamp(epochs, format="seconds") -%}
    {%- if format != "seconds" -%}
    {{ exceptions.raise_compiler_error(
        "value " ~ format ~ " for `format` for from_unixtimestamp is not supported."
        )
    }}
    {% endif -%}
    to_timestamp({{ epochs }})
{%- endmacro %}

{%- macro postgres__date__from_unixtimestamp(epochs, format="seconds") -%}
    {%- if format != "seconds" -%}
    {{ exceptions.raise_compiler_error(
        "value " ~ format ~ " for `format` for from_unixtimestamp is not supported."
        )
    }}
    {% endif -%}
    cast(to_timestamp({{ epochs }}) at time zone 'UTC' as timestamp)
{%- endmacro %}

{%- macro snowflake__date__from_unixtimestamp(epochs, format) -%}
    {%- if format == "seconds" -%}
    {%- set scale = 0 -%}
    {%- elif format == "milliseconds" -%}
    {%- set scale = 3 -%}
    {%- elif format == "microseconds" -%}
    {%- set scale = 6 -%}
    {%- else -%}
    {{ exceptions.raise_compiler_error(
        "value " ~ format ~ " for `format` for from_unixtimestamp is not supported."
        )
    }}
    {% endif -%}
    to_timestamp_ntz({{ epochs }}, {{ scale }})

{%- endmacro %}

{%- macro bigquery__date__from_unixtimestamp(epochs, format) -%}
    {%- if format == "seconds" -%}
        timestamp_seconds({{ epochs }})
    {%- elif format == "milliseconds" -%}
        timestamp_millis({{ epochs }})
    {%- elif format == "microseconds" -%}
        timestamp_micros({{ epochs }})
    {%- else -%}
    {{ exceptions.raise_compiler_error(
        "value " ~ format ~ " for `format` for from_unixtimestamp is not supported."
        )
    }}
    {% endif -%}
{%- endmacro %}

{%- macro trino__date__from_unixtimestamp(epochs, format) -%}
    {%- if format == "seconds" -%}
        cast(from_unixtime({{ epochs }}) AT TIME ZONE 'UTC' as {{ dbt.type_timestamp() }})
    {%- elif format == "milliseconds" -%}
        cast(from_unixtime_nanos({{ epochs }} * pow(10, 6)) AT TIME ZONE 'UTC' as {{ dbt.type_timestamp() }})
    {%- elif format == "microseconds" -%}
        cast(from_unixtime_nanos({{ epochs }} * pow(10, 3)) AT TIME ZONE 'UTC' as {{ dbt.type_timestamp() }})
    {%- elif format == "nanoseconds" -%}
        cast(from_unixtime_nanos({{ epochs }}) AT TIME ZONE 'UTC' as {{ dbt.type_timestamp() }})
    {%- else -%}
    {{ exceptions.raise_compiler_error(
        "value " ~ format ~ " for `format` for from_unixtimestamp is not supported."
        )
    }}
    {% endif -%}

{%- endmacro %}


{%- macro duckdb__date__from_unixtimestamp(epochs, format="seconds") -%}
    {%- if format != "seconds" -%}
    {{ exceptions.raise_compiler_error(
        "value " ~ format ~ " for `format` for from_unixtimestamp is not supported."
        )
    }}
    {% endif -%}
    cast(to_timestamp({{ epochs }}) at time zone 'UTC' as timestamp)
{%- endmacro %}
