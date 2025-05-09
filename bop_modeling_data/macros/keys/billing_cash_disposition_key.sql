
{% macro billing_cash_disposition_key(
    bil_account_id='BIL_ACCOUNT_ID',
    bil_dtb_dt='BIL_DTB_DT',
    bil_dtb_seq_nbr='BIL_DTB_SEQ_NBR',
    bil_dsp_seq_nbr='BIL_DSP_SEQ_NBR',
    bil_dsp_dt='BIL_DSP_DT'
) -%}
    sha256(
        concat(
            {{ bil_account_id }},
            {{ bil_dtb_dt }},
            {{ bil_dsp_dt }},
            {{ bil_dtb_seq_nbr }},
            {{ bil_dsp_seq_nbr }}
        )
    ) as billing_cash_disposition_key
{%- endmacro %}