with

raw as (
    {% if env_var('IS_ANDY_LAPTOP', '0') == '1' %}
    select 'nada' as nothing
    {% else %}
    select *
        from read_csv_auto('{{ var("raw_csv_loc") }}/screngn__bil_account.csv')
    {% endif %}
)

select * 
from raw