{%- test assert_string_matches_regex(model, column_name, regex) -%}
    {% set column_name = kwargs.get('column_name') %}
    {% set regex = kwargs.get('regex') %}

    select
        *
    from {{ model }}
    where not {{ column_name }} ~ {{ regex }}
{%- endtest -%}