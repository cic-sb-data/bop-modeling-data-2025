{%- macro recode__experian_date_of_data(column) -%}
try_cast(substring({{ column }}, 1, 2) || '/01/' || substring({{ column }}, 3, 4) as date)
{%- endmacro -%}