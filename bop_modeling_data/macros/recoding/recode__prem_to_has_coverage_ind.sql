{%- set prem_cols=["data_defender","network_defender","prop","bpp","building","eq","eq_bpp","eq_building","liab","cyber","hno_liab","prof_liab"] -%}

{%- macro recode__prem_to_has_coverage_ind(old_column, new_column) -%}
case
    when try_cast({{ old_column }} as float) > 0 then 1
    when try_cast({{ old_column }} as float) <= 0 then 0
    else 0
end as {{ new_column }},
{%- endmacro -%}

{%- macro recode_cols() -%}
    {% for col in prem_cols %}
        {{ recode__prem_to_has_coverage_ind(col ~ '_prem', 'has_' ~ col) }}
    {% endfor %}
{%- endmacro -%}
