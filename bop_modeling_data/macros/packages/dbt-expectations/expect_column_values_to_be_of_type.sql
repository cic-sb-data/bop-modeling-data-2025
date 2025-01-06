{%- test expect__expect_column_values_to_be_of_type(model, column_name, column_type) -%}
{{ test_expect__expect_column_values_to_be_in_type_list(model, column_name, [column_type]) }}
{%- endtest -%}

