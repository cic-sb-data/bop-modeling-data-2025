{# generate_lookup -- deduped step
    ------------------------------------------------------------
    This macro generates the deduped step for the lookup, which selects distinct rows from the cleaned data.
    It orders the results by the specified columns to ensure consistent row numbering. #}
{% macro _generate_lookup__deduped(cols, input_tbl) -%}
    select distinct {{ cols | join(', ') }}
    from {{ input_tbl }}
    order by {{ cols | join(', ') }}
{%- endmacro %} 