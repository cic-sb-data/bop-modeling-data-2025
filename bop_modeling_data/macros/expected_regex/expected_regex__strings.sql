{%- macro expected_regex__string__no_spaces_no_punct() -%}
{%- set return_value='([a-zA-Z0-9]+|Missing|Excluded)' -%}
{{ return_value }}
{%- endmacro -%}

{%- macro expected_regex__string__with_spaces_no_punct() -%}
{%- set return_value='([a-zA-Z0-9 ]+|Missing|Excluded)' -%}
{{ return_value }}
{%- endmacro -%}

{%- macro expected_regex__string__no_spaces_with_punct() -%}
{%- set return_value='([a-zA-Z0-9.,\"\'-]+|Missing|Excluded)' -%}
{{ return_value }}
{%- endmacro -%}

{%- macro expected_regex__string__with_spaces_with_punct() -%}
{%- set return_value='(([a-zA-Z0-9.,\"\'- ]|[ ])+|Missing|Excluded)' -%}
{{ return_value }}
{%- endmacro -%}