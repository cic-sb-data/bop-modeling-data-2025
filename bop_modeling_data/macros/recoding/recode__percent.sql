{% macro recode__percent(column_name) -%}
        case
            when median(try_cast({{ column_name }} as double)) over () > 1 then try_cast({{ column_name }} as double) / 100
            else try_cast({{ column_name }} as double)
        end
{%- endmacro %}