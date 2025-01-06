{%- macro is_uw_involved(column_name) -%}
case
    when {{column_name}} = 1 then 0
    else 1
end as is_uw_involved
{%- endmacro -%}
