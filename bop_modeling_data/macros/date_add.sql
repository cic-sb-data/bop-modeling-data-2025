{% macro date_add(datepart, interval, date_expr) %}
    {%- set adapter = target.type -%}
    {%- if adapter in ['snowflake', 'redshift', 'postgres'] -%}
        dateadd({{ datepart }}, {{ interval }}, {{ date_expr }})
    {%- elif adapter == 'bigquery' -%}
        datetime_add({{ date_expr }}, INTERVAL '{{ interval }} {{ datepart | upper }}')
    {%- elif adapter == 'duckdb' -%}
        date_add({{ date_expr }}, interval '{{ interval }} {{ datepart | upper }}')
    {%- else -%}
        date_add({{ date_expr }}, interval '{{ interval }} {{ datepart | upper }}')
    {%- endif -%}
{% endmacro %}