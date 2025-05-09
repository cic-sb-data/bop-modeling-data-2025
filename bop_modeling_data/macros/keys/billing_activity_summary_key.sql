{% macro billing_activity_summary_key(
    bil_account_id='BIL_ACCOUNT_ID',
    bil_acy_dt='BIL_ACY_DT',
    bil_acy_seq='BIL_ACY_SEQ'
) -%}
    md5_number(
        concat(
            {{ bil_account_id }},
            {{ bil_acy_dt }},
            {{ bil_acy_seq }}
        ) 
    ) as billing_activity_summary_key
{%- endmacro %}