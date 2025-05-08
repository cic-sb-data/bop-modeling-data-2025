{#%
macro make_prior_year_cols(data, relative_date=policy_eff_date, compare_date=date_of_loss, n_prior_years=5, n_month_lag=4);
    data &data.;
        set &data.;
        %_declareNewVarLengths(&n_prior_years.) 8.;
        %_buildEvalDate(&relative_date., &n_month_lag.);
        %_buildPriorYearCols(&relative_date., &n_prior_years.);

        if date_of_loss > eval_date then nth_prior_year=0;
        else do;
            %_slotTransactionsIntoPriorYears(&compare_date., &n_prior_years.);
        end;
    run;
%mend make_prior_year_cols;
#}

{%- macro make_n_prior_year_cols(
    dataset_name,
    relative_date='policy_eff_date',
    compare_date='billing_activity_date',
    n_prior_years=5,
    n_month_lag=4
) -%}
    with

    raw as (
        select *
        from {{ dataset_name }}
    ),

    add_eval_date as (
        select
            *,
            {{ _build_eval_date(relative_date, n_month_lag) }}

        from raw
    ),

    add_prior_year_columns as (
        select
            *,
            {{ _build_prior_year_cols(relative_date, n_prior_years) }}

        from add_eval_date
    ),

     slot_trans_into_prior_years as (
        select
            *,
            {{ _slot_transactions_into_prior_years(compare_date, 'eval_date', n_prior_years) }} as prior_year

        from add_prior_year_columns
    )

    select *
    from slot_trans_into_prior_years

{%- endmacro -%}

{#
NOT NEEDED--------------------

%macro _declareNewVarLengths(n_prior_years);
    length eval_date 
    %do i=1 %to %eval(&n_prior_years.+1);
        yr&i._prior_date
    %end;
        nth_prior_year
%mend _declareNewVarLengths;

#}

{#
%macro _buildEvalDate(relative_date, n_months);
    eval_date=intnx('month', &relative_date., -&n_months., 's');
%mend _buildEvalDate;
#}

{%- macro _build_eval_date(relative_date, n_months_lag_param) -%}
    {{ _build_n_month_prior_column(relative_date, n_months_lag_param) }} as eval_date
{%- endmacro -%}

{#
%macro _buildNMonthPriorCols(relative_date, n_months=12);
    %let n_yr=%sysfunc(round(%sysevalf(&n_months./12)));
    %let col=yr&n_yr._prior_date;
    &col.=intnx('month', &relative_date., -n_months., 's');
%mend _buildNMonthPriorCols;

#}

{%- macro _build_n_month_prior_column(relative_date, n_months) -%}
    try_cast( {{ relative_date }} - interval {{ n_months }} months as date)
{%- endmacro -%}

{%- macro _build_n_year_prior_column(relative_date, n_years) -%}
    try_cast( {{ relative_date }} - interval {{ n_years }} year as date)
{%- endmacro -%}

{#
%macro _buildPriorYearCols(relative_date, n_prior_years);
    %let finalYear = %eval(&n_prior_years. + 1);
    %do i=1 %to &finalYear.;
        %let m=%eval(12 * &i.);
        %_buildNMonthPriorCols(&relative_date., &m.);
    %end;
%macro _buildPriorYearCols;
#}

{%- macro _build_prior_year_cols(relative_date_col_name, n_prior_years_param) -%}
    {%- for i in range(1, n_prior_years_param + 1) -%}
    {{ dbt.dateadd('month', -1 * i * 12, relative_date_col_name) }} as yr{{i}}_prior_date
    {%- if not loop.last -%},{%- endif -%}
    {%- endfor -%}
{%- endmacro -%}

{%- macro _slot_transactions_into_prior_years(compare_date_col_name, eval_date_col_name, n_prior_years_param) -%}
    CASE
        WHEN {{ compare_date_col_name }} > {{ eval_date_col_name }} THEN 0
        {% for i in range(1, n_prior_years_param + 1) %}
        WHEN {{ compare_date_col_name }} > yr{{i}}_prior_date THEN {{i}}
        {% endfor %}
        ELSE 9999
    END
{%- endmacro -%}
