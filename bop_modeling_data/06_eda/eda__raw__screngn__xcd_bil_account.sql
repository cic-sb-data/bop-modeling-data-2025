{%- set table = 'raw__screngn__xcd_bil_account' -%}
{%- set relation = ref(table) -%}
{%- set columns = adapter.get_columns_in_relation(relation) -%}

with 

raw as (select * from {{ relation }}),

get_stats as (
    with

    {%- for column in columns -%}
        {%- set col = column.column -%}
        {%- set dtype = column.dtype -%}
        {{ log(col ~ " | " ~ dtype ~ " | " ~ column) }}
        
        distinct_values as (
            select distinct
                {% if dtype == 'VARCHAR' %}
                    '{{ col }}' as col_name,
                    array_agg(distinct {{ col }}) as distinct_values
                {% endif %}

                {% if dtype != 'VARCHAR' %}
                    '{{ col }}' as col_name,
                    array_agg(distinct {{ col }}) as distinct_values
                {% endif %}
            from raw 
        ),

        cardinality as (
            select distinct
                '{{ col }}' as col_name,
                len(distinct_values) as n_distinct
            from distinct_values  
        ),

        {{ col }} as (
            select
                distinct_values.*,
                cardinality.* exclude (col_name)

            from distinct_values
            join cardinality    
                on distinct_values.col_name = cardinality.col_name
        ),
        {# {%- if loop.last -%},{%- endif -%} #}
        {% endfor %}

        appended as (
            {%- for column in columns -%}
                {% set col = column.column %}
                select * from {{ col }}
                {% if not loop.last %}union all{% endif %}
            {% endfor %}
        )

        select * 
        from appended 
        where col_name != 'end__'
)

select *
from get_stats