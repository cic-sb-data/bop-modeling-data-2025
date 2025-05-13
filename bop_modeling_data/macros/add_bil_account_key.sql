{%- macro add_bil_account_key(tbl) -%}
    
    with

    raw as (
        select *
        from {{ ref('lkp__xcd_bil_account_key') }}
    ),

    joined as (
        select 
            raw.bil_account_key,
            to_tbl.*

        from {{ tbl }} as to_tbl
        left join raw
            on to_tbl.billing_acct_id = raw.billing_acct_id
    ),

    reordered as (
        select *
        from joined 
    )

    select *
    from reordered

{%- endmacro -%}