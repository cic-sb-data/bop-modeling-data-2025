{% macro expected__month(type) %}
{%- set var = 'month' -%}
{%- if type == 'number' -%}
    ['Missing', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
{%- elif type == 'abbreviation' -%}
    ['Missing', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
{%- elif type == 'name' -%}
    ['Missing', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}