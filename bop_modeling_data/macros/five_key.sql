{%- macro five_key(table='NONE') -%}
    {%- if table_name == 'NONE' -%}
        company_numb,
        policy_sym,
        policy_numb,
        policy_module,
        policy_eff_date
    {%- else -%}
        {{ table_name }}.company_numb,
        {{ table_name }}.policy_sym,
        {{ table_name }}.policy_numb,
        {{ table_name }}.policy_module,
        {{ table_name }}.policy_eff_date
    {%- endif -%}
{%- endmacro -%}

{%- macro five_key_join(table1, table2) -%}

    {{ table1 }}.company_numb = {{ table2 }}.company_numb
    and {{ table1 }}.policy_sym = {{ table2 }}.policy_sym
    and {{ table1 }}.policy_numb = {{ table2 }}.policy_numb
    and {{ table1 }}.policy_module = {{ table2 }}.policy_module
    and {{ table1 }}.policy_eff_date = {{ table2 }}.policy_eff_date

{%- endmacro -%}