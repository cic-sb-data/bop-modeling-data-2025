{%- macro generate_lro_type(class_code) -%}

{%- set class_code -%}
coalesce(try_cast({{ class_code }} as integer), 0) 
{%- endset -%}

case
    when class_code = 10151 then 'office'
    when class_code = 10156 then 'retail_service'
    when class_code = 10157 then 'wholesale_distribution'
    when class_code = 10158 then 'shopping_center'
    else 'other'
end as lro_type

{%- endmacro -%}
