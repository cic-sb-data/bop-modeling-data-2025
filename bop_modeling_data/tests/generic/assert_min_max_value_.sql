-- filepath: /home/aweaver/work/bop-modeling-data-2025/bop_modeling_data/tests/generic/assert_min_max_value_.sql
{% test assert_max_value_lt(model, column_name, max_value) %}
    {% set col = column_name if column_name is not none else kwargs.get('column_name') %}
    {% set maxv = max_value if max_value is not none else kwargs.get('max_value') %}
    select *
    from {{ model }}
    where {{ col }} >= {{ maxv }}
{% endtest %}

{% test assert_max_value_le(model, column_name, max_value) %}
    {% set col = column_name if column_name is not none else kwargs.get('column_name') %}
    {% set maxv = max_value if max_value is not none else kwargs.get('max_value') %}
    select *
    from {{ model }}
    where {{ col }} > {{ maxv }}
{% endtest %}

{% test assert_min_value_gt(model, column_name, min_value) %}
    {% set col = column_name if column_name is not none else kwargs.get('column_name') %}
    {% set minv = min_value if min_value is not none else kwargs.get('min_value') %}
    select *
    from {{ model }}
    where {{ col }} <= {{ minv }}
{% endtest %}

{% test assert_min_value_ge(model, column_name, min_value) %}
    {% set col = column_name if column_name is not none else kwargs.get('column_name') %}
    {% set minv = min_value if min_value is not none else kwargs.get('min_value') %}
    select *
    from {{ model }}
    where {{ col }} < {{ minv }}
{% endtest %}