{%- macro add_bil_acct_key(tbl) -%}
    
    with

    raw as (
        select *
        from {{ ref('xcd_bil_acct_key') }}
    ),

    joined as (
        select 
            raw.bil_acct_key,
            to_tbl.*

        from {{ tbl }} as to_tbl
        left join raw
            on to_tbl.bil_acct_id = raw.bil_acct_id
    ),

    reordered as (
        select *
        from joined 
    )

    select *
    from reordered

{%- endmacro -%}