{% macro recode__sas_date_format(date_column) -%}
        {%- set text_col -%}
            try_cast({{ date_column }} as varchar)
        {%- endset -%}

        try_cast(
            concat(
                right({{ text_col }}, 4),
                '-',
                list_position(
                    ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'],
                    upper(substring({{ text_col }}, 3, 3))
                ),
                '-',
                left({{ text_col }}, 2)
            ) as date
        )
{% endmacro -%}

