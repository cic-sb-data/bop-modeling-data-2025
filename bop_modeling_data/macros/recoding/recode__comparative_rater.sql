{%- macro recode__comparative_rater() -%}
case
    when lower(comparative_rater_vendor) = 'tarmika'
        then 'tarmika'
    when lower(comparative_rater_vendor) = 'eqcl-prod'
        then 'eqcl-prod'
    when lower(comparative_rater_vendor) = 'no vendor name received'
        then 'none'
    when lower(comparative_rater_vendor) = 'missing'
        then 'none'
    else 'other_unknown'
end
{%- endmacro -%}