{%- macro recode__text_ind(old_column, new_column) -%}
case
    when lower(try_cast({{ old_column }} as text)) = 'true' then 1
    when lower(try_cast({{ old_column }} as text)) = 'yes' then 1
    when lower(try_cast({{ old_column }} as text)) = 't' then 1
    when lower(try_cast({{ old_column }} as text)) = 'y' then 1
    when lower(try_cast({{ old_column }} as text)) = '1' then 1
    when lower(try_cast({{ old_column }} as text)) = '1.0' then 1

    when lower(try_cast({{ old_column }} as text)) = 'false' then 0
    when lower(try_cast({{ old_column }} as text)) = 'no' then 0
    when lower(try_cast({{ old_column }} as text)) = 'f' then 0
    when lower(try_cast({{ old_column }} as text)) = 'n' then 0
    when lower(try_cast({{ old_column }} as text)) = '0' then 0
    when lower(try_cast({{ old_column }} as text)) = '0.0' then 0

    when lower(try_cast({{ old_column }} as text)) = 'missing' then 0
    else 0
end as {{ new_column }}
{%- endmacro -%}