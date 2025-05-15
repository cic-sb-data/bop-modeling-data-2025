{%- macro add_bil_key(tbl, xcd_bil_table, primary_keys) -%}
    
    {%- set relation = _get_xcd_bil_relation(xcd_bil_table) -%}
    {%- set key_name = _get_xcd_bil_key_name(xcd_bil_table) -%}
    with

    raw as (select * from {{ ref(relation) }}),

    joined as (
        select 
            raw.{{ key_name }},
            to_tbl.*

        from {{ tbl }} as to_tbl
        left join raw
            on to_tbl.bil_policy_id = raw.bil_policy_id
    ),

    reordered as (
        select *
        from joined 
    )

    select *
    from reordered

{%- endmacro -%}