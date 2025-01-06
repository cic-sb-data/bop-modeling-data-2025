{%- macro date__week_end(date=None, tz=None) -%}
{%-set dt = date if date else date__today(tz) -%}
{{ adapter.dispatch('date__week_end') (dt) }}
{%- endmacro -%}

{%- macro default__date__week_end(date) -%}
{{ last_day(date, 'week') }}
{%- endmacro %}

{%- macro snowflake__date__week_end(date) -%}
{%- set dt = date__week_start(date) -%}
{{ date__n_days_away(6, dt) }}
{%- endmacro %}

{%- macro postgres__date__week_end(date) -%}
{%- set dt = date__week_start(date) -%}
{{ date__n_days_away(6, dt) }}
{%- endmacro %}

{%- macro duckdb__date__week_end(date) -%}
{{ return(postgres__date__week_end(date)) }}
{%- endmacro %}
