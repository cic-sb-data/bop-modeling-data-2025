{%- test expect__expect_table_row_count_to_equal(model,
                                            value,
                                            group_by=None,
                                            row_condition=None
                                            ) -%}
    {{ adapter.dispatch('expect__test_expect_table_row_count_to_equal') (model,
                                                value,
                                                group_by,
                                                row_condition
                                                ) }}
{% endtest %}



{%- macro default__expect__test_expect_table_row_count_to_equal(model,
                                                value,
                                                group_by,
                                                row_condition
                                                ) -%}
{% set expression %}
count(*) = {{ value }}
{% endset %}
{{ expect__expression_is_true(model,
    expression=expression,
    group_by_columns=group_by,
    row_condition=row_condition)
    }}
{%- endmacro -%}
