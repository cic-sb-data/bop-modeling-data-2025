{% macro is_not_missing(col) %}
    CASE WHEN 
        {{ is_missing(col) }} = 1 
            THEN 0 
        ELSE 1 
    END
{% endmacro %}

{% macro is_missing(col) %}
    CASE
        WHEN {{ col }} IS NULL
            THEN 1
        WHEN typeof({{ col }}) = 'null'
            THEN 1
        WHEN typeof({{ col }}) = 'text' 
            THEN {{ is_missing__when_text(col) }}
        WHEN typeof({{ col }}) = 'numeric'
            THEN {{ is_missing__when_numeric(col) }}
        WHEN typeof({{ col }}) = 'date'
            THEN {{ is_missing__when_date(col) }}
        WHEN typeof({{ col }}) = 'timestamp'
            THEN {{ is_missing__when_datetime(col) }} 
        ELSE 0
    END
{% endmacro %}

{% macro is_missing__when_text(col) %}
    CASE
        WHEN lower(trim({{ column_name }})) = 'missing'
            THEN 1
        WHEN lower(trim({{ column_name }})) = 'n/a'
            THEN 1
        WHEN lower(trim({{ column_name }})) = 'na'
            THEN 1
        WHEN lower(trim({{ column_name }})) = ''
            THEN 1
        ELSE 0
    END
{% endmacro %}

{% macro is_missing__when_numeric(col) %}
    CASE
        WHEN {{ col }} IS NULL
            THEN 1
        WHEN {{ col }} = 0
            THEN 1
        ELSE 0
    END
{% endmacro %}

{% macro is_missing__when_date(col) %}
    CASE
        WHEN {{ col }} IS NULL
            THEN 1
        WHEN {{ col }} = '0000-00-00'
            THEN 1
        WHEN {{ col }} = '0001-01-01'
            THEN 1
        WHEN {{ col }} = '9999-12-31'
            THEN 1
    END
{% endmacro %}

{% macro is_missing__when_datetime(col) %}
    CASE
        WHEN {{ col }} IS NULL
            THEN 1
        WHEN {{ col }} = '0000-00-00 00:00:00'
            THEN 1
        WHEN {{ col }} = '0001-01-01 00:00:00'
            THEN 1
        WHEN {{ col }} = '9999-12-31 23:59:59'
            THEN 1
    END
{% endmacro %}