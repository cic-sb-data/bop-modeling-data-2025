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
    )
    {#,

     slot_trans_into_prior_years as (
        select
            *,
            {{ macro _slot_transactions_into_prior_years(compare_date, n_prior_years) }}

        from add_prior_year_columns
    ) #}

    select *
    from add_prior_year_columns

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

{%- macro _build_eval_date(relative_date, n_months=4) -%}
    {{ _build_n_month_prior_column('relative_date', 4) }} as eval_date
{%- endmacro -%}

{#
%macro _buildNMonthPriorCols(relative_date, n_months=12);
    %let n_yr=%sysfunc(round(%sysevalf(&n_months./12)));
    %let col=yr&n_yr._prior_date;
    &col.=intnx('month', &relative_date., -n_months., 's');
%mend _buildNMonthPriorCols;

#}

{%- macro _build_n_month_prior_column(relative_date, n_months) -%}
    ({{ relative_date }} - {{ n_months }} month)
{%- endmacro -%}

{%- macro _build_n_year_prior_column(relative_date, n_years) -%}
    ({{ relative_date }} - {{ n_years }} year)
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

{%- macro _build_prior_year_cols(relative_date, n_prior_years) -%}
    {%- set __final_year = n_prior_years + 1 -%}
    {%- for i in range(__final_year) -%}
        {{ _build_n_year_prior_column(relative_date, i) }} as yr{{ i }}_prior_date{%- if i != __final_year -%},{%- endif -%}
    {%- endfor -%}
{%- endmacro -%}

{#
%macro _slotTransactionsIntoPriorYears(compare_date, n_prior_years);
    if &compare_date. <= yr1_prior_date and &compare_date. > yr2_prior_date 
        then nth_prior_year=1;

    %do i=2 %to %eval(&n_prior_years. + 1);
        %let col1=yr&i._prior_date;

        %let next_yr=%eval(&i.+1);
        %let col2=yr&next_yr._prior_date;

        else if &compare_date. <= &col1.
            and &compare_date. > &col2.
            then nth_prior_year=&i.;
    %end;

    else nth_prior_year=9999;
%mend _slotTransactionsIntoPriorYears;
#}

{%- macro _slot_transactions_into_prior_years(compare_date, n_prior_years) -%}

    {%- set __final_year = n_prior_years + 1 -%}
    case
        when {{ compare_date }} <= yr1_prior_date 
            and {{ compare_date }} > yr2_prior_date
            then 1
        {%- for i in range(__final_year) -%}
            {%- if i > 1 -%}
                {%- set next_yr = i + 1 -%}
                {%- set __col1 = 'yr' ~ i ~ '_prior_date' -%}
                {%- set __col2 = 'yr' ~ next_yr ~ '_prior_date' -%}

                when {{ compare_date }} <= {{ __col1 }}
                    and {{ compare_date }} > {{ __col2 }}
                    then {{ i }}
            {%- endif -%}
        {%- endfor -%}

        else 9999
    end
{%- endmacro -%}
