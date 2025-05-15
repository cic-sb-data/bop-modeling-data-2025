{%- macro bil_table_lookup(xcd_bil_table, primary_keys) -%}
    {%- set relation = _get_xcd_bil_relation(xcd_bil_table) -%}
    {%- set key_name = _get_xcd_bil_key_name(xcd_bil_table) -%}

    {{ log('xcd_bil_table: ' ~ xcd_bil_table) }}
    {{ log('primary_keys:\n' ~ primary_keys) }}
    {{ log('relation:\n' ~ relation) }}
    {{ log('key_name:\n' ~ key_name) }}
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

{%- macro _select_and_rename_cols(primary_keys) -%}
    {% for old, new in primary_keys %}
        {{ log('old:\n' ~ old) }}
        {{ log('new:\n' ~ new) }}
        {{ old }} as {{ new }}{%- if not loop.last -%},{%- endif -%}
    {%- endfor %}
{%- endmacro -%}

{%- macro _get_new_cols(primary_keys) -%}
    {% for old, new in primary_keys %}
        {{ new }}{%- if not loop.last -%},{%- endif -%}
{{ log('xcd-bil-log-8') }}
{%- endmacro -%}

{%- macro _get_xcd_bil_relation(xcd_bil_table) -%}
    {%- set relation='raw__screngn__xcd_bil_' ~ xcd_bil_table -%}
    {{ relation }}
{%- endmacro -%}

{%- macro _get_xcd_bil_key_name(xcd_bil_table) -%}
    {%- set key_name='bil_' ~ xcd_bil_table ~ '_key' -%}
    {{ key_name }}
{%- endmacro -%}

