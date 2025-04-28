{%- macro generate_policy_key(company_numb='company_numb', policy_sym='policy_sym', policy_numb='policy_numb', policy_module='policy_module', policy_eff_date='policy_eff_date') %}
md5_number({{ company_numb }} || {{ policy_sym }} || {{ policy_numb }} || {{ policy_module }} || {{ policy_eff_date }} )
{% endmacro -%}