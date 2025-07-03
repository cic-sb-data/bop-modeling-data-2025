with

raw as (
    select *
    {% if env_var('IS_ANDY_LAPTOP', '0') == '1' %}
        from read_csv_auto('/home/aweaver/work/bop-modeling-data-2025/devdb/decfile__sb_aiv_lookup.csv')
    {% else %}
        from read_csv_auto('{{ var("raw_csv_loc") }}/decfile.aiv_lookup.csv')
    {% endif %}
)

select *
from raw