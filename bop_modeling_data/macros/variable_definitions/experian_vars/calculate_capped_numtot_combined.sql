{% macro calculate_capped_numtot_combined(in_tbl) %}
    {# 
        This macro calculates a capped version of the numtot_combined variable.
        It first imputes missing values with 5, then caps the values at 10.
        The final output includes the original columns and the new capped column.
    #}
    with

    imputed_missing_values as (
        select 
            *,

            {# /* Impute missing values for numtot_combined with 5 */ #}
            {# ,coalesce(t2.numtot_combined,5) as &LOB._numtot_combined_2 #}
            {{ impute_missing_values('numtot_combined', 5) }} as numtot_combined_2,

        from {{ in_tbl }} 
    ),

    capped as (
        select
            *,

            {# /* Capped version of numtot_combined */ #}
            {# min(calculated &LOB._numtot_combined_2, 10) as &LOB._numtot_combined_2_cap10 #}
            min(numtot_combined_2, 10) as numtot_combined_2_cap10

        from imputed_missing_values
    )

    select  *
    from capped
{% endmacro %}