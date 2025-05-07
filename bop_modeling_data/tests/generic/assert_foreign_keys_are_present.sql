-- tests/generic/assert_foreign_keys_are_present.sql
-- This generic test ensures that all foreign keys in a child table
-- exist in the parent table. It's a more specific version of the
-- dbt_utils.relationships test, focusing on ensuring no orphans.

{% test assert_foreign_keys_are_present(model, column_name, field, to) %}

with child_keys as (
    select distinct
        {{ column_name }} as fk_value
    from {{ model }}
    where {{ column_name }} is not null
),

parent_keys as (
    select distinct
        {{ field }} as pk_value
    from {{ to }}
    where {{ field }} is not null
),

missing_keys as (
    select
        ck.fk_value
    from child_keys ck
    left join parent_keys pk
        on ck.fk_value = pk.pk_value
    where pk.pk_value is null
)

select count(*) as missing_key_count
from missing_keys

{% endtest %}
