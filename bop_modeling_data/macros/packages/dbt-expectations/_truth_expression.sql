
{% macro expect__truth_expression(expression) %}
    {{ adapter.dispatch('expect__truth_expression') (expression) }}
{% endmacro %}

{% macro default__expect__truth_expression(expression) %}
  {{ expression }} as expression
{% endmacro %}
