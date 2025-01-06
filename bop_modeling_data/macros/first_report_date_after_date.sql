{%- macro first_report_date_after_date(date_col, new_date_col, source_tbl) %}
select
    * exclude (
        -- these are helper columns that are not needed after this step
        im_year,
        im_year_plus_1,
        im_month,
        im_month_plus_1,
        im_day,
        rpt_day,
        prev_rpt_day,
        error_year,
        month_1,
        month_9
    ),
    case
        when im_year >= 2010 then 
            (case 
                when im_day <= rpt_day then
                    {{ mdy_to_date('im_month', 'rpt_day', 'im_year') }}
                when im_month < 12 and im_day > rpt_day then
                    {{ mdy_to_date('im_month_plus_1', 'rpt_day', 'im_year') }}
                when im_month = 12 and im_day > rpt_day then
                    {{ mdy_to_date('month_1', 'rpt_day', 'im_year_plus_1') }}        
                -- this will function as a code that says this branch failed:
                else {{ mdy_to_date('month_1', 'month_1', 'error_year') }}
            end)
        when im_year = 2009 then
            (case
                when im_month >= 9 and im_day <= prev_rpt_day then
                    {{ mdy_to_date('im_month', 'prev_rpt_day', 'im_year') }}
                when im_month < 12 and im_day > prev_rpt_day then
                    {{ mdy_to_date('im_month_plus_1', 'prev_rpt_day', 'im_year') }}
                when im_month = 12 and im_day > prev_rpt_day then
                    {{ mdy_to_date('month_1', 'rpt_day', 'im_year_plus_1') }}
                -- this will function as a code that says this branch failed:
                else {{ mdy_to_date('month_1', 'rpt_day', 'error_year') }}
            end)

        
        -- this will function as a code that says this branch failed:
        else {{ mdy_to_date('rpt_day', 'rpt_day', 'error_year') }}
    end as {{ new_date_col }}

from (
    select
        *,
        year({{ date_col }}) as im_year,
        year({{ date_col }}) + 1 as im_year_plus_1,
        1 as month_1,
        9 as month_9,
        month({{ date_col }}) as im_month,
        month({{ date_col }})+1 as im_month_plus_1,
        day({{ date_col }}) as im_day,
        2 as rpt_day,
        1 as prev_rpt_day,
        2001 as error_year
    
    from {{ source_tbl }}
)
{% endmacro -%}