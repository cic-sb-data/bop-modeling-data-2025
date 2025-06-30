{%- macro five_key(table='NONE') -%}
    {%- if table == 'NONE' -%}
        company_numb,
        policy_sym,
        policy_numb,
        policy_module,
        policy_eff_date
    {%- else -%}
        {{ table }}.company_numb,
        {{ table }}.policy_sym,
        {{ table }}.policy_numb,
        {{ table }}.policy_module,
        {{ table }}.policy_eff_date
    {%- endif -%}
{%- endmacro -%}

{%- macro five_key_join(table1, table2) -%}

    {{ table1 }}.company_numb = {{ table2 }}.company_numb
    and {{ table1 }}.policy_sym = {{ table2 }}.policy_sym
    and {{ table1 }}.policy_numb = {{ table2 }}.policy_numb
    and {{ table1 }}.policy_module = {{ table2 }}.policy_module
    and {{ table1 }}.policy_eff_date = {{ table2 }}.policy_eff_date

{%- endmacro -%}