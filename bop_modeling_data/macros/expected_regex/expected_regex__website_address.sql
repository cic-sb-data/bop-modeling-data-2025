{%- macro expected_regex__website_address() -%}
{%- set return_value='(((http)s?://)?(\w+)?(\.)?([a-zA-Z]+\.([a-zA-Z]{2}|[a-zA-Z]{3}))(?!\S)|Missing|Excluded)' -%}
{{ return_value }}
{%- endmacro -%}

