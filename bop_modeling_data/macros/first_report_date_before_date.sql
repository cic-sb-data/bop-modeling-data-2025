{%- macro first_report_date_before_date(date_col, new_date_col, source_tbl) %}
select
    * exclude (
        -- these are helper columns that are not needed after this step
        im_year,
        im_year_minus_1,
        im_month,
        im_month_minus_1,
        im_day,
        rpt_day,
        prev_rpt_day,
        error_year
    ),
    case
        when im_year >= 2010 then 
            {# 
            starting in 2010, the monthly batch processing happened on the 2nd of the month
            #}
            (case 
                
                when im_day > rpt_day then
                    -- if the day of the month is after the report day,
                    -- the report month is the current month
                    {{ mdy_to_date('im_month', 'rpt_day', 'im_year') }}
                
                else
                    -- if the day of the month is on or before the report day,
                    -- the report month is the previous month
                    case when im_month = 1 then
                        -- if the current month is January, have to decrement the year
                        -- as well as the month
                        {{ mdy_to_date('month_12', 'rpt_day', 'im_year_minus_1') }}
                    else
                        -- otherwise just decrement the month
                        {{ mdy_to_date('im_month_minus_1', 'rpt_day', 'im_year') }}
                    end
            end)
        
        when im_year = 2009 then
            -- September through December 2009, the monthly batch processing happened
            -- on the 1st of the month. The logic is otherwise the same as 2010
            -- and later, but the report day is different.
            (case
                when im_day > prev_rpt_day then
                    {{ mdy_to_date('im_month', 'prev_rpt_day', 'im_year') }}
                else
                    case when im_month = 1 then
                        {{ mdy_to_date('month_12', 'prev_rpt_day', 'im_year_minus_1') }}
                    else
                        {{ mdy_to_date('im_month_minus_1', 'prev_rpt_day', 'im_year') }}
                    end
            end)

        
        -- this will function as a code that says this branch failed:
        else {{ mdy_to_date('rpt_day', 'rpt_day', 'error_year') }}
    end as {{ new_date_col }}

from (
    select
        *,
        year({{ date_col }}) as im_year,
        year({{ date_col }}) - 1 as im_year_minus_1,
        1 as month_1,
        9 as month_9,
        12 as month_12,
        month({{ date_col }}) as im_month,
        month({{ date_col }})-1 as im_month_minus_1,
        day({{ date_col }}) as im_day,
        2 as rpt_day,
        1 as prev_rpt_day,
        2001 as error_year
    
    from {{ source_tbl }}
)
{% endmacro -%}