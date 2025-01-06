{% test expect__expect_row_values_to_have_recent_data(model,
                                                column_name,
                                                datepart,
                                                interval,
                                                row_condition=None) %}

 {{ adapter.dispatch('expect__test_expect_row_values_to_have_recent_data') (model,
                                                                                        column_name,
                                                                                        datepart,
                                                                                        interval,
                                                                                        row_condition) }}

{% endtest %}

{% macro default__expect__test_expect_row_values_to_have_recent_data(model, column_name, datepart, interval, row_condition) %}
{%- set default_start_date = '1970-01-01' -%}
with max_recency as (

    select max(cast({{ column_name }} as {{ expect__type_timestamp() }})) as max_timestamp
    from
        {{ model }}
    where
        -- to exclude erroneous future dates
        cast({{ column_name }} as {{ expect__type_timestamp() }}) <= {{ date__now() }}
        {% if row_condition %}
        and {{ row_condition }}
        {% endif %}
)
select
    *
from
    max_recency
where
    -- if the row_condition excludes all rows, we need to compare against a default date
    -- to avoid false negatives
    coalesce(max_timestamp, cast('{{ default_start_date }}' as {{ expect__type_timestamp() }}))
        <
        cast({{ dbt.dateadd(datepart, interval * -1, date__now()) }} as {{ expect__type_timestamp() }})

{% endmacro %}
