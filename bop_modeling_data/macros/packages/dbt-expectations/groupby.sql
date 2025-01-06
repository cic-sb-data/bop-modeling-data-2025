{%- macro expect__group_by(n) -%}
    {{ return(adapter.dispatch('expect__group_by')(n)) }}
{% endmacro %}

{%- macro default__expect__group_by(n) -%}

  group by {% for i in range(1, n + 1) -%}
      {{ i }}{{ ',' if not loop.last }}
   {%- endfor -%}

{%- endmacro -%}
