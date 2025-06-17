{#  generate_lookup macro
    ------------------------------------------------------------
    This macro generates a lookup table based on the provided root model and column names.
    It includes steps for base selection, cleaning, and deduplication of the data.
    The macro allows for corrections to be applied to specific columns and handles null values based on the specified strategy.
    The final output includes a surrogate ID and the specified columns. 
    
    Parameters
    ----------
    root : str
        The root model name from which the lookup is generated.
        For example, 'customer' would generate a lookup from the 'raw__customer' model.
    column_names : str | list
        A single column name or a list of column names to include in the lookup.
        If a single column name is provided, it will be used as the only column in the lookup.
        If a list is provided, all specified columns will be included in the lookup.
        For example, ['company_numb', 'policy_sym', 'policy_numb'] would include the unique combinations
        of these columns in the lookup.
    corrections_map : dict, optional
        A dictionary mapping error values to their respective manual corrections. 
        Has no effect if not provided or if the column_names provided are a list.
        Only has an effect if the column_names provided is a single column name, since otherwise
        the column would not be known. 
        If multiple columns need to be corrected, they should first get their own lookup generated,
        and then the surrogate ID of the lookup can be used to join the corrected values
        to the main model.
        For example, if the column_names is 'policy_sym', the corrections_map could be:
        {'policy_sym': {'BPO': 'BOP', 'BOP': 'BOP', 'BOPP': 'BOP'}}.
    null_strategy : str, optional
        The strategy to handle null values in the lookup. 
        Can be 'skip' to exclude rows with null values or 'sentinel' to replace nulls with a sentinel value.
        Defaults to 'sentinel'.
    sentinel_value : str, optional
        The value to use as a sentinel for nulls when the null_strategy is 'sentinel'.
        Defaults to the variable 'null_sentinel', which should be defined in the dbt-project.yml file.

    Returns
    -------
    -------
    A SQL query that generates a lookup table with a surrogate ID and the specified columns.
    The lookup table will include unique combinations of the specified columns, with corrections applied
    and null values handled according to the specified strategy.
    The final output will be ordered by the specified columns.
    The surrogate ID will be generated as a row number based on the order of the specified columns.

    This table should be placed in a lkp__[root]__[surrogate] model, 
    where [root] is the root model name and [surrogate] is the surrogate name generated from the column names.
    For example, if the root is 'customer' and the surrogate name is 'company_numb_id', 
    the model would be named 'lkp__customer__company_numb_id'.
    The model should be placed in the 'models/02_lkp' directory.
    #}
{% macro generate_lookup(
    root,
    column_names,
    corrections_map={},
    null_strategy='sentinel',
    sentinel_value=var('null_sentinel'),
    id_col_name='surrogate_id') -%}

    {%- set cols=_lookups__ensure_cols_is_list(column_names) -%}
    {%- set surrogate_name = _lookups__surrogate_name(id_col_name, cols) -%}
    {%- set input_model = _lookups__input_model_name(root) -%}

    {%- set base_cte_name = 'base__' ~ surrogate_name -%}
    {%- set cleaned_cte_name = 'cleaned__' ~ surrogate_name -%}
    {%- set deduped_cte_name = 'deduped__' ~ surrogate_name -%}

    with 

    {{ base_cte_name }} as (
        {{ _generate_lookup__base(cols, input_model, null_strategy) }}
    ), 

    {{ cleaned_cte_name }} as ( 
        {{ _generate_lookup__cleaned(cols, corrections_map, null_strategy, sentinel_value, base_cte_name) }} 
    ),

    {{ deduped_cte_name }} as (
        {{ _generate_lookup__deduped(cols, cleaned_cte_name) }}
    )

    select
        row_number() over (
            order by {{ cols | join(', ') }}
        ) as {{ surrogate_name }},
        {{ cols | join(', ') }},
        now() as generated_at

    from {{ deduped_cte_name }}
{%- endmacro %}