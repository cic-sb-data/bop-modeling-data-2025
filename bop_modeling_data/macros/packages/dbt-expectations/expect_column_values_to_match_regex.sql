{% test expect__expect_column_values_to_match_regex(model, column_name,
                                                    regex,
                                                    row_condition=None,
                                                    is_raw=False,
                                                    flags=""
                                                    ) %}

{% set expression %}
{{ expect__regexp_instr(column_name, regex, is_raw=is_raw, flags=flags) }} > 0
{% endset %}

{{ expect__expression_is_true(model,
                                        expression=expression,
                                        group_by_columns=None,
                                        row_condition=row_condition
                                        )
                                        }}

{% endtest %}
