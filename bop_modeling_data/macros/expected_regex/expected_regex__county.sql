{%- macro expected_regex__county(type) -%}
    {%- if type == 'clean' -%}
        {%- set county_patterns = '^District of Columbia|New Castle County / Outside Wilmington|^(?!.*\b(?:County|City|Parish)\b)[A-Z][a-z]*' -%}
    {%- elif type == 'raw' -%}
        {%- set county_patterns = '(([A-Z ]+ (COUNTY|CITY|PARISH)$|DISTRICT OF COLUMBIA|NEW CASTLE COUNTY / OUTSIDE WILMINGTON)$|Missing)' -%}
    {%- endif -%}
    {{ county_patterns }}
{%- endmacro -%}