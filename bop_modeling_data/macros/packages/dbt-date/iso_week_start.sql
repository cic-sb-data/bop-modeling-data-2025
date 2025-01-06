{%- macro date__iso_week_start(date=None, tz=None) -%}
{%-set dt = date if date else date__today(tz) -%}
{{ adapter.dispatch('date__iso_week_start') (dt) }}
{%- endmacro -%}

{%- macro __date__iso_week_start(date, week_type) -%}
cast({{ dbt.date_trunc(week_type, date) }} as date)
{%- endmacro %}

{%- macro default__date__iso_week_start(date) -%}
{{ _iso_week_start(date, 'isoweek') }}
{%- endmacro %}

{%- macro snowflake__date__iso_week_start(date) -%}
{{ _iso_week_start(date, 'week') }}
{%- endmacro %}

{%- macro postgres__date__iso_week_start(date) -%}
{{ _iso_week_start(date, 'week') }}
{%- endmacro %}

{%- macro duckdb__date__iso_week_start(date) -%}
{{ return(postgres__date__iso_week_start(date)) }}
{%- endmacro %}

{%- macro spark__date__iso_week_start(date) -%}
{{ _iso_week_start(date, 'week') }}
{%- endmacro %}

{%- macro trino__date__iso_week_start(date) -%}
{{ _iso_week_start(date, 'week') }}
{%- endmacro %}
