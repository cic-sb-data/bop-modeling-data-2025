{% macro years_in_file_normalized(col, yif_col) %}
case when {{ yif_col }} < 1 then {{ col }} else {{ col }} / {{ yif_col }} end
{% endmacro %}