{% macro expect__rand() -%}
    {{ adapter.dispatch('expect__rand') () }}
{%- endmacro %}

{% macro default__expect__rand() -%}

    rand()

{%- endmacro -%}

{% macro bigquery__expect__rand() -%}

    rand()

{%- endmacro -%}

{% macro snowflake__expect__rand(seed) -%}

    uniform(0::float, 1::float, random())

{%- endmacro -%}

{% macro postgres__expect__rand() -%}

    random()

{%- endmacro -%}

{% macro redshift__expect__rand() -%}

    random()

{%- endmacro -%}

{% macro duckdb__expect__rand() -%}

    random()

{%- endmacro -%}
