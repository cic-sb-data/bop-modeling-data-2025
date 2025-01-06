{%- macro generate_policy_location_key(company_numb, policy_sym, policy_numb, policy_module, policy_eff_date, location_numb) -%}

hash({{ company_numb }} || {{ policy_sym }} || {{ policy_numb }} || {{ policy_module }} || {{ policy_eff_date }} ) as policy_key

{%- endmacro -%}