{%- macro generate_is_lro(lro_type, class_code, is_lro) -%}

{%- set class_code -%}
coalesce(try_cast({{ class_code }} as integer), 0) 
{%- endset -%}

{%- if lro_type=='office' -%}
case when {{ class_code }} = 10151 then 1 else 0 end as is_lro_office
{%- elif lro_type=='retail' -%}
case when {{ class_code }} = 10156 then 1 else 0 end as is_lro_retail_service
{%- elif lro_type=='wholesale' -%}
case when {{ class_code }} = 10157 then 1 else 0 end as is_lro_wholesale_distribution
{%- elif lro_type=='shopping_center' -%}
case when {{ class_code }} = 10158 then 1 else 0 end as is_lro_shopping_center
{%- else -%}
case when {{ is_lro }} then 1 else 0 end as is_lro_other
{%- endif -%}

{%- endmacro -%}