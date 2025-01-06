{% test expect__expect_column_min_to_be_between(model, column_name,
                                                    min_value=None,
                                                    max_value=None,
                                                    group_by=None,
                                                    row_condition=None,
                                                    strictly=False
                                                    ) %}
{% set expression %}
min({{ column_name }})
{% endset %}
{{ expect__expression_between(model,
                                        expression=expression,
                                        min_value=min_value,
                                        max_value=max_value,
                                        group_by_columns=group_by,
                                        row_condition=row_condition,
                                        strictly=strictly
                                        ) }}

{% endtest %}
