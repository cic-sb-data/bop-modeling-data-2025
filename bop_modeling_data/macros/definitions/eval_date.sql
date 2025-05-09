{% macro eval_date(date_col, prior_months=4) %}
    {{ date_col }} - interval {{ prior_months }} month
{% endmacro %}