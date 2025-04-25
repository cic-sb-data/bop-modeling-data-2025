{%- macro mdy_to_date(month, day, year) -%}
try_cast(
    concat(
        try_cast({{ year }} as varchar),
        '-',
        try_cast({{ month }} as varchar),
        '-',
        try_cast({{ day }} as varchar)
    ) as date
)
{%- endmacro -%}