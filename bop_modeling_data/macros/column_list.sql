{%- macro column_list(collist)-%} 
    {% for col in collist %}
        {{ col }}{% if not loop.last %},{% endif %}
    {% endfor %}
{%- endmacro -%} 