{%- macro policy_key(
    company_numb='company_numb',  
    policy_sym='policy_sym',
    policy_numb='policy_numb',
    policy_module='policy_module',
    policy_eff_date='policy_eff_date'
) -%}
    md5_number(
        try_cast(company_numb as varchar)
        || policy_sym 
        || try_cast(policy_numb as varchar)
        || try_cast(policy_module as varchar)
        || try_cast(year(policy_eff_date) as varchar)
        || try_cast(month(policy_eff_date) as varchar)
        || try_cast(day(policy_eff_date) as varchar)
    )
{%- endmacro -%}