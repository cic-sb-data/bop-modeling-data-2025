{%- macro transaction_models(tbl_name) -%}
{%- set common_columns = [
    "row_id",
    "policy_key",
    "claim_key",
] -%}

{{ tbl_name }} as (

select
    {{ common_columns | join(', ') }},
    '{{ tbl_name }}' as transaction_type,
    round(try_cast(100 * try_cast('{{ tbl_name }}' as double) as integer), 0) as amount

from raw
where "{{ tbl_name }}" is not null and round("{{ tbl_name }}", 2) != 0
)

{%- endmacro -%}
