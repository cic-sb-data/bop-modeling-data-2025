{% macro apply_lookup(
        root,
        column_names,
        id_col_name='surrogate_id',
        null_strategy='sentinel') -%}

    {%- set cols=_lookups__ensure_cols_is_list(column_names) -%}
    {%- set surrogate_name=_lookups__surrogate_name(id_col_name, cols) -%}
    {%- set source_model = 'raw__' ~ root -%}
    {%- set lookup_model = 'lkp__' ~ root ~ '__' ~ surrogate_name -%}

    select
        lkp.{{ surrogate_name }} as {{ surrogate_name }},
        src.* except(
            {{ cols | join(', ') }}
        )

    from {{ ref(source_model) }} as src
    left join {{ ref(lookup_model) }} as {{ lookup_alias }}
        on
        {%- for c in cols %}
            {{ _lookups__norm_expr(source_alias ~ '.' ~ c,
                                corr.get(c, {}),
                                null_strategy,
                                sentinel_value) }}
            =
            {{ _lookups__norm_expr(lookup_alias ~ '.' ~ c,
                                {},              /* lookup already clean */
                                null_strategy,
                                sentinel_value) }}
            {{ 'and' if not loop.last }}
        {%- endfor %}
{%- endmacro %}