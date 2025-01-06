{%- test expect__expect_table_row_count_to_equal_other_table(model,
                                            compare_model,
                                            group_by=None,
                                            compare_group_by=None,
                                            factor=1,
                                            row_condition=None,
                                            compare_row_condition=None
                                        ) -%}

    {{ adapter.dispatch('expect__test_expect_table_row_count_to_equal_other_table') (model,
                                                compare_model,
                                                group_by,
                                                compare_group_by,
                                                factor,
                                                row_condition,
                                                compare_row_condition
                                            ) }}
{% endtest %}

{%- macro default__expect__test_expect_table_row_count_to_equal_other_table(model,
                                                    compare_model,
                                                    group_by,
                                                    compare_group_by,
                                                    factor,
                                                    row_condition,
                                                    compare_row_condition
                                                    ) -%}
{{ expect__test_equal_expression(model, "count(*)",
    compare_model=compare_model,
    compare_expression="count(*) * " + factor|string,
    group_by=group_by,
    compare_group_by=compare_group_by,
    row_condition=row_condition,
    compare_row_condition=compare_row_condition
) }}
{%- endmacro -%}
