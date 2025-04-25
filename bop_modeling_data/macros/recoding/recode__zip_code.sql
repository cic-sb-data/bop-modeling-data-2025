{%- macro recode__zip_code() -%}
    {%- set column_hierarchy = [
        "zip_code",
        "location_zip_code",
        "first_insured_zip_code",
        "zip_plus_four_code",
        "first_insured_zip_plus_four_code",
    ] -%}
    {%- set zip_code_regex = expected_regex__zip_code('zip_code') -%}
    {%- set zip_plus_four_code_regex = expected_regex__zip_code('zip_plus_four_code') -%}
    {%- set zip_extension_regex = expected_regex__zip_code('zip_extension') -%}

    case 
        {%- for col in column_hierarchy %}
            when {{ col }} ~ '{{ zip_code_regex }}' then {{ col }}
        {%- endfor -%}
        {%- for col in column_hierarchy %}
            when {{ col }} ~ '{{ zip_plus_four_code_regex }}' then left({{ col }}, 5)
        {%- endfor %}
        else null
    end
{%- endmacro -%}