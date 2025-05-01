{%- macro with_ref(ref_name, cte_name) -%}
{{ cte_name }} as (
    select *
    from {{ ref(ref_name) }}
)
{%- endmacro -%}