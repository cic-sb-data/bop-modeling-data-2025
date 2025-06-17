
{# Apply corrections
    ------------------------------------------------------------
    This macro applies corrections to a column based on a dictionary of wrong and right values.
    If the column value matches a key in the dictionary, it replaces it with the corresponding value.
    If no corrections are provided, it returns the original column value.
    The corrections map is expected to be a dictionary where keys are wrong values and values are correct values #}
{% macro _lookups__apply_corrections(col, corr) -%}
    {% if corr -%}
        case
            {%- for wrong, right in corr.items() -%}
                when {{ col }} = '{{ wrong }}' 
                    then '{{ right }}'
            {%- endfor -%}

            else {{ col }}
        end
    {%- else -%}
        {{ col }}
    {%- endif %}
{%- endmacro %}
