{%- test assert_string_matches_regex(model, column_name, regex) -%}
    select *
    from {{ model }}
    where not {{ column_name }} ~ {{ regex }}
{%- endtest -%}