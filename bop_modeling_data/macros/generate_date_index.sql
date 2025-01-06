{%- macro generate_date_index(datecol) -%}
12 * year({{ datecol }}) + month({{ datecol }}) - 1
{%- endmacro -%}