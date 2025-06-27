{% test assert_string_matches_regex(model, column_name, regex) %}
    {% set col = column_name if column_name is not none else kwargs.get('column_name') %}
    {% set rx = regex if regex is not none else kwargs.get('regex') %}
    select *
    from {{ model }}
    where not {{ col }} ~ {{ rx }}
{% endtest %}