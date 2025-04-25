{%- macro init_sql() -%}
create schema if not exists raw;

{{ __init_tbl('gl_aiv') }}
{{ __init_tbl('cf_aiv') }}
{{ __init_tbl('dlf') }}

{%- endmacro -%}


{%- macro __init_tbl(table_name) -%}
    create or replace view raw.{{table_name}} as (
        select *
        from read_csv_auto('{{ var("raw_csv_folder") }}"/{{table_name}}.csv')
    );
{%- endmacro -%}