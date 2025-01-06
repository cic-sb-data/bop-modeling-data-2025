{%- macro date__to_unixtimestamp(timestamp) -%}
    {{ adapter.dispatch('date__to_unixtimestamp') (timestamp) }}
{%- endmacro %}

{%- macro default__date__to_unixtimestamp(timestamp) -%}
    {{ date__date_part('epoch', timestamp) }}
{%- endmacro %}

{%- macro snowflake__date__to_unixtimestamp(timestamp) -%}
    {{ date__date_part('epoch_seconds', timestamp) }}
{%- endmacro %}

{%- macro bigquery__date__to_unixtimestamp(timestamp) -%}
    unix_seconds({{ timestamp }})
{%- endmacro %}

{%- macro spark__date__to_unixtimestamp(timestamp) -%}
    unix_timestamp({{ timestamp }})
{%- endmacro %}

{%- macro trino__date__to_unixtimestamp(timestamp) -%}
    to_unixtime({{ timestamp }} AT TIME ZONE 'UTC')
{%- endmacro %}
