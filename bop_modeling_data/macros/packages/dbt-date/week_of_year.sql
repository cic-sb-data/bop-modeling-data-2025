{%- macro date__week_of_year(date=None, tz=None) -%}
{%-set dt = date if date else date__today(tz) -%}
{{ adapter.dispatch('date__week_of_year') (dt) }}
{%- endmacro -%}

{%- macro default__date__week_of_year(date) -%}
cast({{ date__date_part('week', date) }} as {{ dbt.type_int() }})
{%- endmacro %}

{%- macro postgres__date__week_of_year(date) -%}
{# postgresql 'week' returns isoweek. Use to_char instead.
   WW = the first week starts on the first day of the year #}
cast(to_char({{ date }}, 'WW') as {{ dbt.type_int() }})
{%- endmacro %}

{%- macro duckdb__date__week_of_year(date) -%}
cast(ceil(dayofyear({{ date }}) / 7) as int)
{%- endmacro %}

{# {%- macro spark__date__week_of_year(date) -%}
weekofyear({{ date }})
{%- endmacro %} #}
