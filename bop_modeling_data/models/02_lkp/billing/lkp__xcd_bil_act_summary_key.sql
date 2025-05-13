{%- set xcd_bil_table='act_summary' -%}
{%- set primary_keys = [
    ('BIL_ACCOUNT_ID', 'billing_acct_id'),
    ('BIL_ACY_DT', 'billing_activity_date'),
    ('BIL_ACY_SEQ', 'billing_activity_seq_numb')
]-%}

{%- set key_name = xcd_bil_table ~ '_key' -%}
{%- set relation='raw__screngn__xcd_bil_' ~ xcd_bil_table -%}
{%- set new_cols -%}
{%- endset -%}

with

raw as (
    select distinct 
        {% for (old, new) in primary_keys %}
            {{ old }} as {{ new }}{%- if not loop.last -%},{%- endif -%}
        {% endfor %}
    
    from {{ ref(relation) }}
    order by 
        {% for (_, new) in primary_keys %}
            {{ new }}{%- if not loop.last -%},{%- endif -%}
        {% endfor %}
),

add_key as (
    select 
        row_number() over() as {{ key_name }},
        {% for (_, new) in primary_keys %}
            {{ new }}{%- if not loop.last -%},{%- endif -%}
        {% endfor %}
    from raw
),

sort_table as (
    select *
    from add_key
    order by {{ key_name }}
)

select *
from sort_table