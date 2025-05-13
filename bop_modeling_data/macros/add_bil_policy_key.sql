{%- macro add_bil_policy_key(tbl) -%}
    
    with

    raw as (
        select *
        from {{ ref('lkp__xcd_bil_policy_key') }}
    ),

    joined as (
        select 
            raw.bil_policy_key,
            to_tbl.*

        from {{ tbl }} as to_tbl
        left join raw
            on to_tbl.billing_policy_id = raw.billing_policy_id
    ),

    reordered as (
        select *
        from joined 
    )

    select *
    from reordered

{%- endmacro -%}