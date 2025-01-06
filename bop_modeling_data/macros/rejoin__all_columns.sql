{%- macro rejoin_all_columns(table_list) -%}
select
    raw.row_key,
    raw.quote_id,
    raw.policy_id,
    {%- for tbl in table_list %}
        {{ tbl }}.* exclude (
            row_key,
            quote_id,
            policy_id
        ) {% if not loop.last %},{% endif %}
    {% endfor -%}

from raw
    {% for tbl in table_list %}
        left join {{ tbl }}
            on raw.row_key = {{ tbl }}.row_key
            and raw.quote_id = {{ tbl }}.quote_id
            and raw.policy_id = {{ tbl }}.policy_id
    {% endfor %}

{%- endmacro -%}