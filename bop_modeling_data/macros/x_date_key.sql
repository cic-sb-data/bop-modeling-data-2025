{%- macro x_date_key(date_column) -%}
    hash(
        try_cast({{ date_column }} as varchar)
    ) as {{ date_column }}_key
{%- endmacro -%}