{% macro expect__percentile_cont(field, quantile, partition=None) %}
  {{ adapter.dispatch('expect__quantile') (field, quantile, partition) }}
{% endmacro %}

{% macro default__expect__quantile(field, quantile, partition)  -%}
    percentile_cont({{ quantile }}) within group (order by {{ field }})
    {%- if partition %}over(partition by {{ partition }}){% endif -%}
{%- endmacro %}

{% macro bigquery__expect__quantile(field, quantile, partition) -%}
    percentile_cont({{ field }}, {{ quantile }})
    over({%- if partition %}partition by {{ partition }}{% endif -%})
{% endmacro %}

{% macro spark__expect__quantile(field, quantile, partition) -%}
    percentile({{ field }}, {{ quantile }})
    over({%- if partition %}partition by {{ partition }}{% endif -%})
{% endmacro %}
