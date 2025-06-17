{# Null strategy macro
   ------------------------------------------------------------
   This macro applies a null handling strategy to a column.
   If the strategy is 'sentinel', it replaces nulls with a sentinel value.
   Otherwise, it returns the column as is.
   The sentinel value can be customized by passing a different value to the 'sentinel' parameter
   The default sentinel value is defined in the dbt variable 'null_sentinel' #}
{% macro _lookups__apply_null_strategy(
    col, 
    strategy='sentinel', 
    sentinel=var('null_sentinel')) -%}

    {% if strategy == 'sentinel' -%}
        {{ _lookups__sentinel_strategy(col, sentinel) }}
    {% else -%}
        {{ col }}
    {%- endif %}
{%- endmacro %}
