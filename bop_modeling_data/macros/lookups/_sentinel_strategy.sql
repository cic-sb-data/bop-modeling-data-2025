{# Sentinel strategy for handling nulls
   ------------------------------------------------------------
   This macro replaces null values with a sentinel value, which is defined in the dbt variable 'null_sentinel'
   If the column is not null, it returns the original value
   The sentinel value can be customized by passing a different value to the 'sentinel' parameter #}
{%- macro _lookups__sentinel_strategy(
    col, 
    sentinel=var('null_sentinel')) -%}
    coalesce({{ col }}, '{{ sentinel }}')
{%- endmacro %}

