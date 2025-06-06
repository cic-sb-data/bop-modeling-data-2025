{%- test expect__expect_table_columns_to_contain_set(model, column_list, transform="upper") -%}
{%- if execute -%}
    {%- set column_list = column_list | map(transform) | list -%}
    {%- set relation_column_names = expect___get_column_list(model, transform) -%}
    {%- set matching_columns = expect___list_intersect(column_list, relation_column_names) -%}
    with relation_columns as (

        {% for col_name in relation_column_names %}
        select cast('{{ col_name }}' as {{ dbt.type_string() }}) as relation_column
        {% if not loop.last %}union all{% endif %}
        {% endfor %}
    ),
    input_columns as (

        {% for col_name in column_list %}
        select cast('{{ col_name }}' as {{ dbt.type_string() }}) as input_column
        {% if not loop.last %}union all{% endif %}
        {% endfor %}
    )
    select *
    from
        input_columns i
        left join
        relation_columns r on r.relation_column = i.input_column
    where
        -- catch any column in input list that is not in the list of table columns
        r.relation_column is null
{%- endif -%}
{%- endtest -%}
