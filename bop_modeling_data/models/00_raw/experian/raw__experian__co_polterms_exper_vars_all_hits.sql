
with

raw as (
    select *
    {% if env_var('IS_ANDY_LAPTOP', '0') == '1' %}
        from read_csv_auto('/home/aweaver/work/bop-modeling-data-2025/devdb/experian.csv')
    {% else %}
        from read_csv_auto('{{ var("raw_csv_loc") }}/experian.csv')
    {% endif %}
)

select *
from raw