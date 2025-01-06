
{%- macro coalesce_credit_variables(column, default) -%}

{%- set tbl1='credit_vars__experian_5_2' -%}
{%- set tbl2='credit_vars__experian_2_8' -%}
{%- set tbl3='credit_vars__mosum_after_rpt_date' -%}
{%- set tbl4='credit_vars__mosum_before_rpt_date' -%}

coalesce(
    "{{ tbl1 }}"."{{ column }}",
    "{{ tbl2 }}"."{{ column }}",
    "{{ tbl3 }}"."{{ column }}",
    "{{ tbl4 }}"."{{ column }}"
)

{%- endmacro -%}