
{%- set is_not_missing_var_needed=[
    'experian_bin',
    'baltot',
    'alltrades',
    'ballate_all_dbt',
    'numtot_combined',
    'pay_sat',
    'judgmentcount',
    'liencount',
    'bankruptcy_cnt',
]-%}

{# These counts are heavily-skewed, so we use the median to impute missing values. #}
{%- set to_impute_with_0=[
    'judgmentcount',
    'liencount',
    'bankruptcy_cnt'
]-%}

{# Two sets of positive-value indicators needed, first before some transformations, second after. #}
{%- set needs_pos_value_indicators_1=[
    'alltrades',
    'baltot',
    'numtot_combined',
    'baltot_combined'
]-%}
{%- set needs_pos_value_indicators_2=[
    'judgmentcount_2',
    'liencount_2',
    'bankruptcy_cnt_2'
]-%}

with

selected_cols as (
    select
        associated_policy_key,
        date_of_data_dt,
        experian_bin,
        commercial_intelliscore,
        yearsinfile,
        alltrades,
        baltot,
        ballate_all_dbt,
        numtot_combined,
        baltot_combined,
        judgmentcount,
        liencount,
        bankruptcy_cnt,
        ttc038,
        ttc039
    from {{ ref('stg__experian') }}
),

-- Note that the column names are maintained exactly as they were originally definined 
-- in prior models, but may not accurately reflect the data they contain, or the intent 
-- behind the particular variable.
bin_hit_vars as (
    select 
        *,
        {{ experian_bin_hit('experian_bin') }} as bin_hit,
        {{ commercial_intelliscore_hit('commercial_intelliscore') }} as exp_hit

    from selected_cols
),

positive_value_indicators_1 as (
    select
        *,

        {% for col in needs_pos_value_indicators_1 %}
            {{ is_variable_positive(col) }} as {{ col }}_positive{% if not loop.last %},{% endif %}
        {% endfor %}

    from bin_hit_vars
),

calculate_pay_sat as (
    select
        *,
        {{ calculate_pay_sat() }} as pay_sat

    from positive_value_indicators_1
),

add_is_not_missing_vars as (
    select
        *,
        {% for col in is_not_missing_var_needed %}
            {{ is_not_missing(col) }} as {{ col }}_source{% if not loop.last %},{% endif %}
        {% endfor %}

    from calculate_pay_sat
),

impute_missing_with_0 as (
    select
        *,
        {% for col in to_impute_with_0 %}
            {{ impute_missing_values(col, 0) }} as {{ col }}_2{% if not loop.last %},{% endif %}
        {% endfor %}

    from calculate_pay_sat
),

other_imputed_values as (
    select
        *,

		{# ,coalesce(t2.ballate_all_dbt,.0071) as &LOB._ballate_all_dbt_2 #}
        {{ impute_missing_values('ballate_all_dbt', 0.0071) }} as ballate_all_dbt_2,

		{# ,coalesce(pay_sat,.9444) as &LOB._pay_sat_2 #}
        {{ impute_missing_values('pay_sat', 0.9444) }} as pay_sat_2


        {# /* Median-imputed variables */
        /* 0 means Missing and 1 Available			*/ #}
		{# ,coalesce(t2.bin,t3.EXPERIAN_BIN_m1,t3.EXPERIAN_BIN_0) as BIN_2 #}

		{# ,coalesce(t2.baltot,t3.BAL_TOT_m1,t3.BAL_TOT_0) as &LOB._BalTot_2 #}

		{# ,coalesce(t2.alltrades,t3.ALL_TRADE_CNT_m1,t3.ALL_TRADE_CNT_0) as &LOB._AllTrades_2 #}

		{# ,coalesce(t2.commercial_intelliscore,t3.COML_INTELSCR_m1,t3.COML_INTELSCR_0,60) as &LOB._commercial_intelliscore_2 #}

		{# ,Max(coalesce(t2.commercial_intelliscore,t3.COML_INTELSCR_m1,t3.COML_INTELSCR_0,60),25) as &LOB._Floor25_Intelliscore_2 #}

			{# /*The EP WAv of Prop_commercial_intelliscore_2 with hits is 56.215584018 & for GL is 59.612505395*/
			/*We decided to set the default for missing values to the lower multiple of 5, i. 55 and floored at 25*/ #}
		{# ,Case When Missing(coalesce(t2.commercial_intelliscore,t3.COML_INTELSCR_m1,t3.COML_INTELSCR_0)) Then 0 Else 1 End as &LOB._Comm_intelliscore_Source #}

		{# ,coalesce(t2.yearsinfile,t3.NBR_YR_IN_FILE_m1,t3.NBR_YR_IN_FILE_0,21) as &LOB._yearsinfile_2 #}

		{# ,Case When Missing(coalesce(t2.yearsinfile,t3.NBR_YR_IN_FILE_m1,t3.NBR_YR_IN_FILE_0)) Then 0 Else 1 End as &LOB._yearsinfile_Source #}

    from impute_missing_with_0

),

capped_baltot_combined as ( {{ calculate_capped_baltot_combined() }} ),
capped_numtot_combined as ( {{ calculate_capped_numtot_combined() }} ),

positive_value_indicators_2 as (
    select
        *,
        
        {% for col in needs_pos_value_indicators_2 %}
            {{ is_variable_positive(col) }} as {{ col }}_2_yn{% if not loop.last %},{% endif %}
        {% endfor %}

    from capped_numtot_combined
),

calculate_log_model_score as (
    select
        *,
        case 
            when bin_hit = 0 
                then null
            else  0.2856 * alltrades_positive
                - 0.2987 * alltrades_positive * pay_sat_2
                + 0.0588 * baltot_positive
                + 0.0724 * baltot_positive * ballate_all_dbt_2
                - 0.0216 * numtot_combined_positive * numtot_combined_2_cap10
                + 0.0116 * baltot_combined_positive * baltotk_combined_y_2_cap10
                + 0.2204 * judgmentcount_2_yn
                + 0.1311 * liencount_2_yn
                + 0.1514 * bankruptcy_cnt_2_yn
        end as log_credit_score

    from positive_value_indicators_2
),

imputed_missing_log_credit_score as (
    select
        *,
        {{ impute_missing_values('log_credit_score', 0) }} as log_credit_score_2

    from calculate_log_model_score
),

missing_log_credit_score_col as (
    select
        *,
        {{ is_not_missing('log_credit_score') }} as log_credit_score_source

    from imputed_missing_log_credit_score
),

final as (
    select  
        associated_policy_key,
        log_credit_score_2 as log__expcr_score,
        log_credit_score_source as is_log__expcr_score_missing

    from missing_log_credit_score_col
    order by associated_policy_key
)

select *
from final
