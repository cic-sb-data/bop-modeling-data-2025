{%- macro recode__yes_no_ind(old_column, new_column) -%}
case
    when try_cast({{ old_column }} as text) = 'Yes' then 1
    when try_cast({{ old_column }} as text) = 'No' then 0
    when try_cast({{ old_column }} as text) = 'Missing' then 0
    else 0
end as {{ new_column }}
{%- endmacro -%}