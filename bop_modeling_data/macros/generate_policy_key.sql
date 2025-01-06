{%- macro generate_policy_key(company_numb, policy_sym, policy_numb, policy_module, policy_eff_date) -%}

hash({{ company_numb }} || {{ policy_sym }} || {{ policy_numb }} || {{ policy_module }} || {{ policy_eff_date }} ) as policy_key

{%- endmacro -%}