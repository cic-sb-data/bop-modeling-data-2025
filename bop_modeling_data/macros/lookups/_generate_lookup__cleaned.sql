{#  generate_lookup -- cleaned step
    ------------------------------------------------------------
    This macro generates the cleaned step for the lookup, which applies corrections and null strategies to the selected columns.
    It uses the _lookups__apply_corrections and _lookups__apply_null_strategy macros to process each column based on the provided corrections map and null strategy. #}
{% macro _generate_lookup__cleaned(cols, corrections_map, null_strategy, sentinel_value, input_tbl) -%}
    select
        {%- for c in cols %}
            {{ _lookups__apply_corrections(
                _lookups__apply_null_strategy(c, null_strategy, sentinel_value),
                corrections_map.get(c, {})
            ) }} as {{ c }}{{ ',' if not loop.last }}
        {%- endfor %}
    from {{ input_tbl }}
{%- endmacro %}
