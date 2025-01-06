{% test expect__expect_column_values_to_not_be_null(model, column_name, row_condition=None) %}

{% set expression = column_name ~ " is not null" %}

{{ expect__expression_is_true(model,
                                        expression=expression,
                                        group_by_columns=None,
                                        row_condition=row_condition
                                        )
                                        }}
{% endtest %}
