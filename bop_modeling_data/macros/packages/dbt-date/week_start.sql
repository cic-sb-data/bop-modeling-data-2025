{%- macro date__week_start(date=None, tz=None) -%}
{%-set dt = date if date else date__today(tz) -%}
{{ adapter.dispatch('date__week_start') (dt) }}
{%- endmacro -%}

{%- macro default__date__week_start(date) -%}
cast({{ dbt.date_trunc('week', date) }} as date)
{%- endmacro %}

{%- macro snowflake__date__week_start(date) -%}
    {#
        Get the day of week offset: e.g. if the date is a Sunday,
        date__day_of_week returns 1, so we subtract 1 to get a 0 offset
    #}
    {% set off_set = date__day_of_week(date, isoweek=False) ~ " - 1" %}
    cast({{ dbt.dateadd("day", "-1 * (" ~ off_set ~ ")", date) }} as date)
{%- endmacro %}

{%- macro postgres__date__week_start(date) -%}
-- Sunday as week start date
cast({{ dbt.dateadd('day', -1, dbt.date_trunc('week', dbt.dateadd('day', 1, date))) }} as date)
{%- endmacro %}

{%- macro duckdb__date__week_start(date) -%}
{{ return(postgres__date__week_start(date)) }}
{%- endmacro %}
