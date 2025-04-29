{%- macro test_policy_eff_date_in_expected_range(model_name, date_col='policy_eff_date') -%}
    select {{ date_col }} as policy_eff_date
    from {{ ref('model_name') }}
    where 
        {{ date_col }} >= {{ var('policy_eff_date__max_yrmo') }}
        or {{ date_col }} <= {{ var('policy_eff_date__min_yrmo') }}
{%- endmacro -%}