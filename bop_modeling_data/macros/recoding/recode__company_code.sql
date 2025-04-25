{% macro recode__company_code(column_name) -%}
        case
            when lower({{ column_name }}) = 'cic' then 5
            when lower({{ column_name }}) = 'ccc' then 7
            when lower({{ column_name }}) = 'cid' then 3
            when lower({{ column_name }}) = 'csu' then 1
            else null
        end
{%- endmacro %}