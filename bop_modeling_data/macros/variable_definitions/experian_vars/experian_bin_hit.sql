{# This macro checks if a bin column is null or missing and returns 0 if it is, otherwise returns 1. #}

{%- macro experian_bin_hit(bin_col) -%}
    case 
        when {{ bin_col }} is null 
            then 0
        else 1
    end
{%- endmacro -%}