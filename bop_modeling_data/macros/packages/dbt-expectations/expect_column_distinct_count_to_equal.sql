{% test expect__expect_column_distinct_count_to_equal(model,
                                                column_name,
                                                value,
                                                group_by=None,
                                                row_condition=None
                                                ) %}
{% set expression %}
count(distinct {{ column_name }}) = {{ value }}
{% endset %}
{{ expect__expression_is_true(model,
                                        expression=expression,
                                        group_by_columns=group_by,
                                        row_condition=row_condition)
                                        }}
{%- endtest -%}
