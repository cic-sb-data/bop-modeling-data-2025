{%- macro logit(column_name) -%}
    case
        when {{ column_name }} <= 0 or {{ column_name }} >= 1 then null
        else log({{ column_name }} / (1 - {{ column_name }}))
    end as logit__{{ column_name }}
{%- endmacro -%}
