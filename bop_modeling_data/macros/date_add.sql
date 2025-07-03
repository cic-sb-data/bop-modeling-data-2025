{% macro date_add(datepart, interval, date_expr) %}
    {%- set adapter = target.type -%}
    {%- if adapter in ['snowflake', 'redshift', 'postgres'] -%}
        dateadd({{ datepart }}, {{ interval }}, {{ date_expr }})
    {%- elif adapter == 'bigquery' -%}
        datetime_add({{ date_expr }}, INTERVAL '{{ interval }} {{ datepart | upper }}')
    {%- elif adapter == 'duckdb' -%}
        try_cast(
            try_cast(
                date_add({{ date_expr }}, interval '{{ interval }} {{ datepart | upper }}') as date
            ) as timestamp
        )
    {%- else -%}
        try_cast(
            try_cast(
                date_add({{ date_expr }}, interval '{{ interval }} {{ datepart | upper }}') as date
            ) as timestamp
        )
    {%- endif -%}
{% endmacro %}