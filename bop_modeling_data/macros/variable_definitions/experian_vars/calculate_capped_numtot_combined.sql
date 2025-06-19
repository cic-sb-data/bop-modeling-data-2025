{% macro calculate_capped_numtot_combined() %}
    with

    imputed_missing_values as (
        select 
            *,

            {# /* Impute missing values for numtot_combined with 5 */ #}
            {# ,coalesce(t2.numtot_combined,5) as &LOB._numtot_combined_2 #}
            {{ impute_missing_values('numtot_combined', 5) }} as numtot_combined_2,

        from capped_baltot_combined 
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