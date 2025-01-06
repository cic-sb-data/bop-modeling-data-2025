{%- macro date__iso_week_end(date=None, tz=None) -%}
{%-set dt = date if date else date__today(tz) -%}
{{ adapter.dispatch('date__iso_week_end') (dt) }}
{%- endmacro -%}

{%- macro _iso_week_end(date, week_type) -%}
{%- set dt = date__iso_week_start(date) -%}
{{ date__n_days_away(6, dt) }}
{%- endmacro %}

{%- macro default__date__iso_week_end(date) -%}
{{ _iso_week_end(date, 'isoweek') }}
{%- endmacro %}

{%- macro snowflake__date__iso_week_end(date) -%}
{{ _iso_week_end(date, 'weekiso') }}
{%- endmacro %}
