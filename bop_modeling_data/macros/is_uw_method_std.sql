{%- macro is_uw_method_std(column_name) -%}
case
    when {{column_name}} = 'STD' then 1
    else 0
end as is_uw_method_std
{%- endmacro -%}
