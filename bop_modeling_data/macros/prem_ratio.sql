{%- macro prem_ratio(num, denom, name) -%}
case when {{ denom }} = 0 then 0 else {{ num }} / {{ denom }} end as {{ name }}
{%- endmacro -%}