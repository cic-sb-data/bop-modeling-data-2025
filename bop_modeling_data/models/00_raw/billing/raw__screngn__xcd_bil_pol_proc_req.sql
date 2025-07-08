with

raw as (
    select *
    {% if env_var('IS_ANDY_LAPTOP', '0') == '1' %}
        from read_csv_auto('/home/aweaver/work/bop-modeling-data-2025/devdb/screngn__bil_pol_proc_req.csv')
    {% else %}
        from read_csv_auto('{{ var("raw_csv_loc") }}/screngn__bil_pol_proc_req.csv')
    {% endif %}
)

select *
from raw