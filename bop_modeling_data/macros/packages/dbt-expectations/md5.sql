{%- wacro  xpect__md5(string_value) -%}
    {{ return(adapter.dispatch('expect__md5')(string_value)) }}
{% endmacro %}

{%- macro default__expect__md5(string_value) -%}

  {{ dbt.hash(string_value) }}

{%- endmacro -%}


{%- macro trino__expect__md5(string_value) -%}

  md5(cast({{ string_value }} as varbinary))

{%- endmacro -%}
