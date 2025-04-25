{# There is at least one version of city name in the form: City, ST (2-digit state abbreviation). 
This macro will try to extract just the city. #}

{%- macro recode__citystate_to_city(column) -%}

regexp_replace(
    regexp_replace(
        {{ column }}, 
        ', [A-Z][A-Z]', 
        ''
    ),
    ',[]+', {# remove trailing commas and whatever comes after them #}
    ''
)

{%- endmacro -%}