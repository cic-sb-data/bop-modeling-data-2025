{%- test assert_max_value_lt(model, column_name, max_value) -%}

    {% set column_name = kwargs.get('column_name') %}
    {% set max_value = kwargs.get('max_value') %}

    select
        *
    from {{ model }}
    where {{ column_name }} >= {{ max_value }}

{%- endtest -%}

{%- test assert_max_value_le(model, column_name, max_value) -%}

    {% set column_name = kwargs.get('column_name') %}
    {% set max_value = kwargs.get('max_value') %}

    select
        *
    from {{ model }}
    where {{ column_name }} > {{ max_value }}

{%- endtest -%}


{%- test assert_min_value_gt(model, column_name, min_value) -%}

    {% set column_name = kwargs.get('column_name') %}
    {% set min_value = kwargs.get('min_value') %}

    select
        *
    from {{ model }}
    where {{ column_name }} <= {{ min_value }}

{%- endtest -%}


{%- test assert_min_value_ge(model, column_name, min_value) -%}

    {% set column_name = kwargs.get('column_name') %}
    {% set min_value = kwargs.get('min_value') %}

    select
        *
    from {{ model }}
    where {{ column_name }} < {{ min_value }}

{%- endtest -%}
