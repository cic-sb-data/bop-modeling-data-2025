{%- macro date__n_months_ago(n, tz=None) -%}
{%- set n = n|int -%}
{{ dbt.date_trunc('month',
    dbt.dateadd('month', -1 * n,
        date__today(tz)
        )
    ) }}
{%- endmacro -%}
