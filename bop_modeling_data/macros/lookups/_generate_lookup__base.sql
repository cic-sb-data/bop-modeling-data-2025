{#  generate_lookup -- base step
    ------------------------------------------------------------
    This macro generates the base step for the lookup, which selects the specified columns from the input model.
    It applies a null strategy if specified, filtering out rows with null values if the strategy is 'skip'.
    If no null strategy is specified, it selects all rows. #}
{% macro _generate_lookup__base(cols, input_model, null_strategy) -%}
    select {{ cols | join(', ') }}
    from {{ ref(input_model) }}
    {% if null_strategy == 'skip' %}
        where {%- for c in cols -%} {{ c }} is not null{{ ' and' if not loop.last }}{% endfor %}
    {% endif %}
{%- endmacro  -%}
