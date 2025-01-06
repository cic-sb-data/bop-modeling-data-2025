{%- test expect__expect_table_row_count_to_be_between(model,
                                                min_value=None,
                                                max_value=None,
                                                group_by=None,
                                                row_condition=None,
                                                strictly=False
                                            ) -%}
    {{ adapter.dispatch('expect__test_expect_table_row_count_to_be_between') (model,
                                                min_value,
                                                max_value,
                                                group_by,
                                                row_condition,
                                                strictly
                                                ) }}
{% endtest %}

{%- macro default__expect__test_expect_table_row_count_to_be_between(model,
                                                min_value,
                                                max_value,
                                                group_by,
                                                row_condition,
                                                strictly
                                                ) -%}
{% set expression %}
count(*)
{% endset %}
{{ expect__expression_between(model,
    expression=expression,
    min_value=min_value,
    max_value=max_value,
    group_by_columns=group_by,
    row_condition=row_condition,
    strictly=strictly
    ) }}
{%- endmacro -%}
