{%- macro recode__unit() -%}
case
    when lower(unit) = 'cccc'
        then 'cccc'
    when lower(unit) = 'commercial lines'
        then 'sbiz'
    when lower(unit) = 'small business'
        then 'sbiz'
    else 'other_unknown'
end
{%- endmacro -%}