{% macro expect__log_natural(x) -%}
    {{ adapter.dispatch('expect__log_natural') (x) }}
{%- endmacro %}

{% macro default__expect__log_natural(x) -%}

    ln({{ x }})

{%- endmacro -%}

{% macro bigquery__expect__log_natural(x) -%}

    ln({{ x }})

{%- endmacro -%}

{% macro snowflake__expect__log_natural(x) -%}

    ln({{ x }})

{%- endmacro -%}

{% macro spark__expect__log_natural(x) -%}

    ln({{ x }})

{%- endmacro -%}
