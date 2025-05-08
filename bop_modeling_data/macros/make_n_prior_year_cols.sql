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

{%- macro _build_prior_year_cols(relative_date, n_prior_years) -%}
    {# SAS logic: yr(i)_prior_date = relative_date - (i*12) months.
       For n_prior_years buckets (1 to N), we need N+1 boundaries:
       yr1_prior_date, yr2_prior_date, ..., yr(N+1)_prior_date.
    #}
    {%- set num_boundaries = n_prior_years + 1 -%}
    {%- for i in range(1, num_boundaries + 1) -%} {# Loop i from 1 to n_prior_years + 1 #}
        {%- set months_to_subtract = i * 12 -%}
        {{ _build_n_month_prior_column(relative_date, months_to_subtract) }} as yr{{ i }}_prior_date
        {%- if not loop.last -%},{%- endif -%}
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

{%- macro _slot_transactions_into_prior_years(compare_date, eval_date_col_name, n_prior_years) -%}
    {#
        Replicates SAS logic:
        1. If compare_date > eval_date, then 0.
        2. Else (compare_date <= eval_date):
           - Slot into buckets 1 to n_prior_years.
             Bucket i is (yr(i+1)_prior_date, yr(i)_prior_date].
           - If older than all defined buckets (i.e., <= yr(n_prior_years+1)_prior_date), then 9999.
        Requires yr1_prior_date to yr(n_prior_years+1)_prior_date to be defined.
    #}
    case
        when {{ compare_date }} is null then null
        when {{ compare_date }} > {{ eval_date_col_name }} then 0
        {# compare_date <= eval_date_col_name and compare_date is not null for subsequent conditions #}
        {# Bucket 1: (yr2_prior_date, yr1_prior_date] #}
        when {{ compare_date }} <= yr1_prior_date and {{ compare_date }} > yr2_prior_date then 1
        {# Buckets 2 to n_prior_years #}
        {%- for i in range(2, n_prior_years + 1) -%} {# Loop i from 2 to n_prior_years #}
            {%- set current_yr_boundary_col = 'yr' ~ i ~ '_prior_date' -%}
            {%- set next_yr_boundary_col = 'yr' ~ (i + 1) ~ '_prior_date' -%}
            when {{ compare_date }} <= {{ current_yr_boundary_col }}
                 and {{ compare_date }} > {{ next_yr_boundary_col }}
                then {{ i }}
        {%- endfor -%}
        {# If compare_date <= eval_date_col_name but did not fit into buckets 1 to n_prior_years, it's older. #}
        {# This means compare_date <= yr(n_prior_years+1)_prior_date (oldest boundary for defined buckets) #}
        when {{ compare_date }} <= {{ 'yr' ~ (n_prior_years + 1) ~ '_prior_date' }} then 9999 {# Corrected condition #}
        else null {# Should ideally not be reached if compare_date and eval_date are not null #}
    end
{%- endmacro -%}
