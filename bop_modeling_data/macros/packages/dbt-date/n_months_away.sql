{%- macro date__n_months_away(n, tz=None) -%}
{%- set n = n|int -%}
{{ dbt.date_trunc('month',
    dbt.dateadd('month', n,
        date__today(tz)
        )
    ) }}
{%- endmacro -%}
