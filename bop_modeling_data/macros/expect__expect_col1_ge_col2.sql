{%- macro expect__expect_col1_ge_col2(
    model,
    col1,
    col2,
    row_condition=None
) -%}

{%- set expression -%}
    coalesce(try_cast({{ col1 }} as double), 0.0) >= coalesce(try_cast({{ col2 }} as double), 0.0)
{%- endset -%}

{{ expect__expression_is_true(
    model,
    expression=expression,
    group_by_columns=None,
    row_condition=row_condition
) }}

{%- endmacro -%}
