{%- macro log1p(column_name) -%}
case 
    when 1 + {{ column_name }} <= 0 then null
    else log(1 + {{ column_name }})
end as log1p__{{ column_name }}
{%- endmacro -%}

{%- macro exp1m(column_name) -%}
exp(log1p__{{ column_name }}) - 1 as {{ column_name }}
{%- endmacro -%}