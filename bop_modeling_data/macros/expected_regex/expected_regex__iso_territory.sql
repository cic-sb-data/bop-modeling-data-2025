{%- macro expected_regex__iso_territory() -%}
    {%- set iso_territory_patterns = '([07]\d{2}|Missing|Excluded)' -%}

    {{ return(iso_territory_patterns) }}
{%- endmacro -%}
