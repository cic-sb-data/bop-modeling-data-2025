{% macro calculate_capped_baltot_combined(in_tbl) %}
    with

    normalize_by_years_in_file as (
        select 
            *,
            {# ,case when calculated &LOB._yearsinfile_2 le 1 then t2.baltot_combined else t2.baltot_combined / calculated &LOB._yearsinfile_2 end as &LOB._baltot_combined_y #}
            {{ years_in_file_normalized('baltot_combined', 'yearsinfile_2') }} as baltot_combined_y

        from {{ in_tbl }}
    ),

    impute_missing_values as (
        select
            *,
            {# ,coalesce(calculated &LOB._baltot_combined_y,127.78) as &LOB._baltot_combined_y_2	 #}
            {{ impute_missing_values('baltot_combined_y', 127.78) }} as baltot_combined_y_2,

        from normalize_by_years_in_file
    ),

    in_thousands as (
        select
            *,

            {# /* Median-imputed version, in thousands */ #}
            {# calculated baltot_combined_y_2 / 1000 as baltotk_combined_y_2, #}
            baltot_combined_y_2 / 1000 as baltotk_combined_y_2

        from impute_missing_values
    ),

    capped as (
        select 
            *,

            {# /* Median-imputed version, in thousands, capped at 10 */ #}
            {# min(calculated baltotk_combined_y_2, 10) as baltotk_combined_y_2_cap10, #}
            min(baltotk_combined_y_2, 10) as baltotk_combined_y_2_cap10

        from in_thousands
    )

    select *
    from capped
{% endmacro %}