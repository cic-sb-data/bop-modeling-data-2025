{%- macro calculate_capped_baltot_combined(in_tbl) -%}
with 

normalize_by_years_in_file as (
    select *, {{ years_in_file_normalized('baltot_combined', 'yearsinfile_2') }} as baltot_combined_y
    from {{ in_tbl }}
), 

impute_missing_values as (
    select *, {{ impute_missing_values('baltot_combined_y', 127.78) }} as baltot_combined_y_2,
    from normalize_by_years_in_file
), 

in_thousands as (
    select *, baltot_combined_y_2 / 1000 as baltotk_combined_y_2
    from impute_missing_values
), 

capped as (
    select *, min(baltotk_combined_y_2, 10) as baltotk_combined_y_2_cap10
    from in_thousands
)

select * from capped
{%- endmacro -%}