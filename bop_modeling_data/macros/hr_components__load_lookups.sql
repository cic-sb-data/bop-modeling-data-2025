{%- macro hr_components__load_lookups(lookup_list) -%}

{%- for lookup_name in lookup_list -%}
    {{ hr_components__load_one_lookup(lookup_name) }} {%- if not loop.last -%}, {%- endif -%}
{%- endfor -%}

{%- endmacro -%}

{%- macro hr_components__load_one_lookup(lookup_name) -%}
{{ lookup_name }} as (from {{ ref('hr_components__' ~ lookup_name) }})
{%- endmacro -%}
