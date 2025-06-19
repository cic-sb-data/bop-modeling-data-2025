{# This macro assumes that the input table contains the columns `ttc039` and `ttc038`.
   It calculates the pay satisfaction ratio by dividing `ttc039` by `ttc038`.
   Uses a case statement to handle division by zero and other similar issues. #}

{%- macro calculate_pay_sat() -%}
    {# /* Others derived from raw variables */
    ,input(t2.ttc039,8.) / input(t2.ttc038,8.) as pay_sat #}

    case
        when ttc038 = 0 or ttc038 is null then null
        else ttc039 / ttc038
    end
    
{%- endmacro -%}
