{# This macro is used to impute missing values in a column `col` with a default value `default`. #}
{% macro impute_missing_values(col, default) -%}
coalesce({{ col }},{{ default }})
{% endmacro %}