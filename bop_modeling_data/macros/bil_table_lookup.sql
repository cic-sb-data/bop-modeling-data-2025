{%- macro bil_table_lookup(xcd_bil_table, primary_keys) -%}
    {%- set relation = _get_xcd_bil_relation(xcd_bil_table) -%}
    {%- set key_name = _get_xcd_bil_key_name(xcd_bil_table) -%}

{{ log('xcd-bil-log-1') }}
    with

    raw as (
        select distinct {{ _select_and_rename_cols(primary_keys) }}
        from {{ ref(relation) }}
        order by {{ _get_new_cols(primary_keys) }}
    ),

{{ log('xcd-bil-log-2') }}
    add_key as (
        select 
            row_number() over() as {{ key_name }},
            {{ _get_new_cols(primary_keys) }}
        from raw
    ),

{{ log('xcd-bil-log-3') }}
    sort_table as (
        select *
        from add_key
        order by {{ key_name }}
    )

{{ log('xcd-bil-log-4') }}
    select *
    from sort_table

{%- endmacro -%}

{%- macro _select_and_rename_cols(primary_keys) -%}
{{ log('xcd-bil-log-5') }}
    {% for old, new in primary_keys %}
        {{ old }} as {{ new }}{%- if not loop.last -%},{%- endif -%}
    {%- endfor %}
{{ log('xcd-bil-log-6') }}
{%- endmacro -%}

{%- macro _get_new_cols(primary_keys) -%}
{{ log('xcd-bil-log-7') }}
    {% for old, new in primary_keys %}
        {{ new }}{%- if not loop.last -%},{%- endif -%}
    {%- endfor %}
{{ log('xcd-bil-log-8') }}
{%- endmacro -%}

{%- macro _get_xcd_bil_relation(xcd_bil_table) -%}
{{ log('xcd-bil-log-9') }}
    {%- set relation='raw__screngn__xcd_bil_' ~ xcd_bil_table -%}
    {{ relation }}
{{ log('xcd-bil-log-10') }}
{%- endmacro -%}

{%- macro _get_xcd_bil_key_name(xcd_bil_table) -%}
{{ log('xcd-bil-log-11') }}
    {%- set key_name='bil_' ~ xcd_bil_table ~ '_key' -%}
    {{ key_name }}
{{ log('xcd-bil-log-12') }}
{%- endmacro -%}

