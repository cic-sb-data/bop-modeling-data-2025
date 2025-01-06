{% macro recode__sas_date_format(date_column) -%}
        try_cast(
            concat(
                right({{ date_column }}, 4),
                '-',
                list_position(
                    ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'],
                    upper(substring({{ date_column }}, 3, 3))
                ),
                '-',
                left({{ date_column }}, 2)
            ) as date
        )
{% endmacro -%}

