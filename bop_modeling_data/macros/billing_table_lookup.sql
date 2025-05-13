
{%- macro _select_and_rename_cols(primary_keys) -%}
    {% for (old, new) in primary_keys %}
        {{ old }} as {{ new }}{%- if not loop.last -%},{%- endif -%}
    {% endfor %}
{%- endmacro -%}

{%- macro _get_new_cols(primary_keys) -%}
    {% for (old, new) in primary_keys %}
        {{ new }}{%- if not loop.last -%},{%- endif -%}
    {% endfor %}
{%- endmacro -%}

{%- macro _get_xcd_bil_relation(xcd_bil_table) -%}
    {%- set relation='raw__screngn__xcd_bil_' ~ xcd_bil_table -%}
    {{ relation }}
{%- endmacro -%}

{%- macro _get_xcd_bil_key_name(xcd_bil_table) -%}
    {%- set key_name = 'bil_' ~ xcd_bil_table ~ '_key' -%}
    {{ key_name }}
{%- endmacro -%}


{%- macro billing_table_lookup(xcd_bil_table, primary_keys) -%}
    {%- set relation = _get_xcd_bil_relation(xcd_bil_table) -%}
    {%- set key_name = _get_xcd_bil_key_name(xcd_bil_table) -%}

    with

    raw as (
        select distinct {{ _select_and_rename_cols(primary_keys) }}
        from {{ ref(relation) }}
        order by {{ _get_new_cols(primary_keys) }}
    ),

    add_key as (
        select 
            row_number() over() as {{ key_name }},
            {{ _get_new_cols(primary_keys) }}
        from raw
    ),

    sort_table as (
        select *
        from add_key
        order by {{ key_name }}
    )

    select *
    from sort_table

{%- endmacro -%}