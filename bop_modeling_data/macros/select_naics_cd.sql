{%- macro select_naics_cd() -%}

case 
    when bop_primary_naics != '000000' and bop_primary_naics != 'Missing' then bop_primary_naics
    when account_naics_code != '000000' and account_naics_code != 'Missing' then account_naics_code
    when experian_first_naics_code != '000000' and experian_first_naics_code != 'Missing' then experian_first_naics_code
    when first_insured_naics_code != '000000' and first_insured_naics_code != 'Missing' then first_insured_naics_code
    when experian_second_naics_code != '000000' and experian_second_naics_code != 'Missing' then experian_second_naics_code
    when experian_third_naics_code != '000000' and experian_third_naics_code != 'Missing' then experian_third_naics_code
    when experian_fourth_naics_code != '000000' and experian_fourth_naics_code != 'Missing' then experian_fourth_naics_code
    else 'Missing'
end as naics_cd

{%- endmacro -%}