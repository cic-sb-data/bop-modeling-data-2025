{% macro expected__policy_sub_status_desc(type) %}
{%- set var = 'policy_sub_status_desc' -%}
{%- if type == 'raw' -%}
    [
        'Missing',
        'Agency did not write account',
        'CLD Finalizing',
        'Class of Business',
        'Declined Supporting Lines of B',
        'Field Rep Review',
        'Financial Condition',
        'Form Deficiencies',
        'In Progress',
        'Inactive State',
        'Inadequate Information',
        'Inadequate Review Time',
        'Issued in eVolve',
        'Lack of Supporting Business',
        'Loss History',
        'Management',
        'Moved to eCLAS',
        'No Agency Response',
        'No Response From Insured',
        'Other',
        'Pending Inspection',
        'Pricing Competition',
        'Quote Bound',
        'Quote Released',
        'Rating',
        'Referred to CSU',
        'Referred to Middle Market',
        'Referred to Small Business',
        'Review Prior to Rating',
        'Submitted by another agency',
        'Underwriting concerns'
    ]
{%- elif type == 'clean' -%}
    [
        'Agency did not write account',
        'CLD Finalizing',
        'Class of Business',
        'Declined Supporting Lines of B',
        'Field Rep Review',
        'Financial Condition',
        'Form Deficiencies',
        'In Progress',
        'Inactive State',
        'Inadequate Information',
        'Inadequate Review Time',
        'Issued in eVolve',
        'Lack of Supporting Business',
        'Loss History',
        'Management',
        'Moved to eCLAS',
        'No Agency Response',
        'No Response From Insured',
        'Other',
        'Pending Inspection',
        'Pricing Competition',
        'Quote Bound',
        'Quote Released',
        'Rating',
        'Referred to CSU',
        'Referred to Middle Market',
        'Referred to Small Business',
        'Review Prior to Rating',
        'Submitted by another agency',
        'Underwriting concerns'
    ]
{%- else -%}
    'Error: Invalid type provided to expected__{{ var }} macro'
{%- endif -%}
{% endmacro %}
